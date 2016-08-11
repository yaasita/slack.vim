" vim: set sw=4 et fdm=marker:
"
"
" slack.vim - edit slack channels
"
" Version: 0.32
" Maintainer:	yaasita < https://github.com/yaasita/slack.vim >
" Last Change:	2015/06/05.

let g:yaasita_slack_hash = 0

function! slack#OpenCh(slack_url) "{{{
    if !g:yaasita_slack_hash
        call s:CreateHash()
    endif
    let tmpfile = tempname()
    if a:slack_url == "slack://ch/"
        e slack://ch/
        call s:ShowChIndex()
        return
    endif
    "let tmpfile = "/tmp/slack" "debug
    let ch_name = matchstr(a:slack_url,'\v[a-zA-Z0-9\-_]+$')
    let ch_id = s:Channel2ID(ch_name)
    call system('curl -s -H "Accept-Encoding: gzip" "https://slack.com/api/channels.history?token=' . 
                \ g:yaasita_slack_token . '&channel=' . ch_id . '&pretty=1" | gunzip -c > ' . tmpfile)
    call s:ConvertText(tmpfile)
    setlocal nomod
    exe "e ".tmpfile
    exe "bw! ".a:slack_url
    exe "f " . a:slack_url
    exe "bw! ".tmpfile
    redr!
    normal! G
endfunction "}}}
function! slack#WriteCh(slack_url) "{{{
    if a:slack_url == "slack://ch/"
        set nomod
        call slack#OpenCh(a:slack_url)
    endif
    let server_name = matchstr(a:slack_url,'\v[a-zA-Z0-9\-_]+$')
    let server_id = s:Channel2ID(server_name)
    perl << EOF
    my $i = $curbuf->Count();
    my @data;
    while ( $i > 1 ){
        my $line = $curbuf->Get($i);
        unshift (@data,$line);
        if ($line =~ /^=== input ===/){
            last;
        }
        $i--;
    }
    if ($data[0] =~ /^=== input ===/ and @data >= 2){
        shift @data;
        my $urlenc = "";
        for (@data){
            chomp;
            my $str = $_ . "\n";
            $str =~ s/([^ 0-9a-zA-Z])/"%".uc(unpack("H2",$1))/eg;
            $str =~ s/ /+/g;
            $urlenc .= $str;
        }
        $urlenc =~ s/%0A$//;
        my $API_TOKEN = VIM::Eval("g:yaasita_slack_token");
        my $SERVER_ID = VIM::Eval("server_id");
        system("curl -s 'https://slack.com/api/chat.postMessage?token=${API_TOKEN}&channel=${SERVER_ID}&text=${urlenc}&as_user=1&pretty=1' > /dev/null") and die $!;
    }
EOF
    call slack#OpenCh(a:slack_url)
endfunction "}}}
function! s:ConvertText(source_file) "{{{
    perl << EOF
    use Encode;
    use Time::Piece;
    use Time::Seconds;
    my $srcfile = VIM::Eval("a:source_file");
    open (my $fh,"<",$srcfile) or die $!;
    my @data = <$fh>;
    close $fh;
    open (my $wr, ">", $srcfile) or die $!;
    for (@data){
        chomp;
        my $line = $_;
        unless ($line =~ /"text"|"user"|"ts"|"url_private_download"/) {
            next;
        }
        while ($line =~ /((?:\\u[0-9a-f]{4})+)/g){
            my $hex_string = $1;
            my $utf_string = $1;
            $utf_string =~ s/\\u//g;
            $utf_string = decode("utf-16be",pack("H*",$utf_string) );
            $line =~ s/\Q$hex_string\E/$utf_string/g;
        }
        $line =~ s/^.*"user": "(\w+)".*/$users{$1}\: /;
        $line =~ s/^.*"text"\: "(.+)".+/$1 /;
        $line =~ s/<@(\w+?)>/"@".$users{$1}/e;
        $line =~ s/"url_private_download"\: "(.+)".+/\nfile: $1\n/;
        $line =~ s#\\/#/#g;
        my $t = localtime();
        $line =~ s/^.*"ts"\: "(\d+)\.\d+"/$t = Time::Piece->strptime($1, '%s') and $t = $t + ONE_HOUR * 9 and $t->strftime("%Y-%m-%d %H:%M:%S")."\n"/e;
        print $wr encode("utf-8",$line);
    }
    close $wr;
    # 逆順にする
    open (my $fh2,"<",$srcfile) or die $!;
    my @line = <$fh2>;
    close $fh2;
    open (my $wr2, ">",$srcfile) or die $!;
    for (reverse @line){
        s/\\n/\n     /g;
        s/&gt;/>/g;
        s/&lt;/</g;
        print $wr2 $_;
    }
    print $wr2 "\n\n=== input ===\n";
    close $wr2;
EOF
endfunction "}}}
function! s:Channel2ID(ch_name) "{{{
    if !g:yaasita_slack_hash
        call s:CreateHash()
    endif
	perl << EOF
        my $ch_name = VIM::Eval("a:ch_name");
        VIM::DoCommand("return '" . $channels{$ch_name} . "'");
EOF
endfunction "}}}
function! s:CreateHash() "{{{
    perl << EOF
        use File::Temp qw/ tempfile tempdir /;
        use Cwd;
        my $wdir = getcwd;
        my $tempdir = tempdir(CLEANUP => 1);
        chdir $tempdir;
        my $API_TOKEN=VIM::Eval("g:yaasita_slack_token");

        # ch hash
        system("curl -s -H 'Accept-Encoding: gzip' 'https://slack.com/api/channels.list?token=${API_TOKEN}&pretty=1' | gunzip -c > channels_list.txt") and die $!;
        our %channels;
        open (my $fh, "<", 'channels_list.txt') or die $!;
        {
            my ($id,$name);
            while(<$fh>){
                if (/"id": "(\w+)"/){
                    $id = $1;
                }
                elsif (/"name": "([\w\-]+)"/){
                    $name = $1;
                    $channels{$name}=$id;
                }
            }
        }
        close $fh;

        # user hash
        system("curl -s -H 'Accept-Encoding: gzip' 'https://slack.com/api/users.list?token=${API_TOKEN}&pretty=1' | gunzip -c > user_list.txt") and die $!;
        our %users;
        $users{"USLACKBOT"}="slackbot"; # slack bot 追加
        open (my $fh, "<", 'user_list.txt') or die $!;
        {
            my ($id,$name);
            while(<$fh>){
                if (/"id": "(\w+)"/){
                    $id = $1;
                }
                elsif (/"name": "([\w\-\.]+)"/){
                    $name = $1;
                    $users{$id}=$name;
                }
            }
        }
        close $fh;
        chdir $wdir;
EOF
    let g:yaasita_slack_hash = 1
endfunction "}}}
function! s:ShowChIndex() "{{{
    perl << EOF
    my @line = sort keys %channels;
    $_ = "slack://ch/$_" for @line;
    $curbuf->Append(1, @line);
EOF
    setlocal nomod
endfunction "}}}
