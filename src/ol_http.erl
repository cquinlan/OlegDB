%%% HTTP responses/headers.
-module(ol_http).
-export([get_response/2,
         not_found_response/0,
         post_response/0,
         deleted_response/0,
         continue_you_shit_response/0,
         bucket_meta_response/2,
         bucket_meta_response/3,
         error_response/1
        ]).

get_response(ContentType, Data) ->
    io_lib:format(
        <<"HTTP/1.1 200 OK\r\n"
        "Server: OlegDB/fresh_cuts_n_jams\r\n"
        "Content-Type: ~s\r\n"
        "Content-Length: ~p\r\n"
        "Connection: close\r\n"
        "\r\n~s">>, [ContentType, byte_size(Data), Data]).

not_found_response() ->
    <<"HTTP/1.1 404 Not Found\r\n"
    "Status: 404 Not Found\r\n"
    "Server: OlegDB/fresh_cuts_n_jams\r\n"
    "Content-Length: 26\r\n"
    "Connection: close\r\n"
    "Content-Type: text/plain\r\n"
    "\r\n"
    "These aren't your ghosts.\n">>.

post_response() ->
    <<"HTTP/1.1 200 OK\r\n"
    "Server: OlegDB/fresh_cuts_n_jams\r\n"
    "Content-Type: text/plain\r\n"
    "Connection: close\r\n"
    "Content-Length: 7\r\n"
    "\r\n"
    "無駄\n">>.

deleted_response() ->
    <<"HTTP/1.1 200 OK\r\n"
    "Server: OlegDB/fresh_cuts_n_jams\r\n"
    "Content-Type: text/plain\r\n"
    "Content-Length: 44\r\n"
    "Connection: close\r\n"
    "\r\n"
    "The wind whispers through your empty forest.\n">>.

continue_you_shit_response() ->
    <<"HTTP/1.1 100 Continue\r\n"
    "Server: OlegDB/fresh_cuts_n_jams\r\n"
    "Content-Length: 0\r\n"
    "\r\n">>.

bucket_meta_response(ContentType, RcrdCnt, Expires) ->
    io_lib:format(
      <<"HTTP/1.1 200 OK\r\n"
        "Server: OlegDB/fresh_cuts_n_jams\r\n"
        "Content-Length: 0\r\n"
        "Content-Type: ~s\r\n"
        "X-OlegDB-Rcrd-Cnt: ~p\r\n"
        "Expires: ~p\r\n"
        "\r\n">>, [ContentType, RcrdCnt, Expires]).

bucket_meta_response(ContentType, RcrdCnt) ->
    io_lib:format(
      <<"HTTP/1.1 200 OK\r\n"
        "Server: OlegDB/fresh_cuts_n_jams\r\n"
        "Content-Length: 0\r\n"
        "Content-Type: ~s\r\n"
        "X-OlegDB-Rcrd-Cnt: ~p\r\n"
        "\r\n">>, [ContentType, RcrdCnt]).

error_response(Data) ->
    io_lib:format(
        <<"HTTP/1.1 500 Internal Server Error\r\n"
        "Server: OlegDB/fresh_cuts_n_jams\r\n"
        "Content-Length: ~p\r\n"
        "\r\n"
        "~s">>, [byte_size(Data), Data]).
