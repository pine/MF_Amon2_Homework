package Homework::Web::Dispatcher;
use strict;
use warnings;
use utf8;
use Amon2::Web::Dispatcher::RouterBoom;

# 判定処理
sub is_time_include {
    my ($comp, $begin, $end) = @_;
    
    # 日を跨いでいる場合、区間を分割
    if ($begin > $end) {
        return (&is_time_include($comp, $begin, 24) or
                &is_time_include($comp, 0,      $end));
    }
    
    # 開始時間と同じ場合
    if ($begin == $comp) { return 1; }
    
    # 開始時間より後で、終了時間より前にある場合
    if ($begin < $comp and $end > $comp) { return 1; }
    
    # その他の場合
    return 0;
}

any '/' => sub {
    my ($c) = @_;
    
    # パラメーターを受け取り
    my $begin = $c->req->param('begin');
    my $end   = $c->req->param('end');
    my $comp  = $c->req->param('comp');
    
    # テンプレートパラメーター (初期値)
    my %tmpl_args = (
        begin => '',
        end   => '',
        comp  => ''
    );
    
    # パラメーターのフォーマットが正しければ、演算処理
    if (defined($begin) and defined($end) and defined($comp)) {
        if ($begin !~ /\D/ and $end !~ /\D/ and $comp !~ /\D/) {
            # テンプレートパラメーターに保存
            $tmpl_args{"begin"} = $begin;
            $tmpl_args{"end"}   = $end;
            $tmpl_args{"comp"}  = $comp;
            
            # 整数に変換
            $begin = int($begin);
            $end   = int($end);
            $comp  = int($comp);
            
            # 判定処理
            $tmpl_args{"included"} = &is_time_include($comp, $begin, $end);
        }
    }
    
    return $c->render('index.tx', \%tmpl_args);
};

1;
