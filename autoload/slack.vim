" vim: set sw=4 et fdm=marker:
"
"
" r2puki2.vim - Convert RedmineWiki to Pukiwiki
"
" Version: 0.2
" Maintainer:	yaasita < https://github.com/yaasita/r2puki2 >
" Last Change:	2015/03/26.

let w:yaasita_slack_hash = 0

function! slack#OpenCh(slack_url) "{{{
    let tmpfile = tempname()
    let server_name = matchstr(a:slack_url,'\v[a-zA-Z0-9\-]+$')
    let server_id = s:Channel2ID(server_name)
    call system('curl -s "https://slack.com/api/channels.history?token=' . g:yaasita_slack_token . '&channel=' . server_id . '&pretty=1" > ' . tmpfile)
    call s:ConvertText(tmpfile)
    exe "e ".tmpfile
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
        unless ($line =~ /"text"|"user"|"ts"/) {
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
        print $wr2 $_;
    }
    close $wr2;
EOF
endfunction "}}}
function! s:Channel2ID(ch_name) "{{{
    if !w:yaasita_slack_hash
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
        my $tempdir = tempdir(CLEANUP => 0);
        chdir $tempdir;
        my $API_TOKEN=VIM::Eval("g:yaasita_slack_token");

        # server hash
        system("curl -s 'https://slack.com/api/channels.list?token=${API_TOKEN}&pretty=1' > channels_list.txt") and die $!;
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
        system("curl -s 'https://slack.com/api/users.list?token=${API_TOKEN}&pretty=1' > user_list.txt") and die $!;
        our %users;
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
EOF
    let b:yaasita_slack_server_hash = 1
endfunction "}}}
