%%% HTTP parsing.
-module(ol_parse).
-include("olegdb.hrl").
-export([parse_http/1]).
-define(KEY_SIZE, 32). % Should match the one in include/oleg.h

parse_db_name_and_key(Data) ->
    [FirstLine|_] = binary:split(Data, [<<"\r\n">>]),
    % Actually Verb Url HttpVersion\r\n:
    [Verb, Url|_] = binary:split(FirstLine, [<<" ">>], [global]),
    ParsedUrl = parse_url(Url),
    case Verb of
        <<"GET">>    -> {get, ParsedUrl};
        <<"POST">>   -> {post, ParsedUrl};
        <<"HEAD">>   -> {head, ParsedUrl};
        <<"DELETE">> -> {delete, ParsedUrl};
        Chunk ->
            {error, <<"Didn't understand your verb.">>, Chunk}
    end.

parse_url(Url) ->
    Split = binary:split(Url, [<<"/">>], [global]),
    %io:format("S: ~p~n", [Split]),
    case Split of
        [<<>>, <<>>] -> {error, <<"No database or key specified.">>};
        % Url was like /users/1 or /pictures/thing
        [_, <<DB_Name/binary>>, <<Key/binary>> |_] -> {ok, DB_Name, Key};
        % Url was like //key. Bad!
        [_, <<>>, <<Key/binary>> |_] -> {ok, Key};
        % The url was like /test or /what, so just assume the default DB.
        [_, <<Key/binary>> |_] -> {ok, Key}
    end.

parse_http(Data) ->
    case parse_db_name_and_key(Data) of
        {ReqType, {ok, DB_Name, Key}} ->
            {ok, ReqType, parse_header(Data,
                    #ol_record{database=DB_Name,key=Key}
                )};
        {ReqType, {ok, Key}} ->
            {ok, ReqType, parse_header(Data, #ol_record{key=Key})};
        X -> X
    end.

parse_header(Data, Record) ->
    Split = binary:split(Data, [<<"\r\n\r\n">>]),
    %io:format("Split: ~p~n", [Split]),
    case Split of
        [Header,PostedData|_] ->
            LowercaseHeader = ol_util:bits_to_lower(Header),
            parse_header1(binary:split(LowercaseHeader, [<<"\r\n">>], [global]),
                          { Record#ol_record{value=PostedData}, []});
        X -> X
    end.

%% Tail recursive function that maps over the lines in a header to fill out
%% an ol_record to later.
parse_header1([], {Record, Options}) -> {Record, Options};
parse_header1([Line|Header], {Record, Options}) ->
    case Line of
        <<"expect: 100-continue">> ->
            parse_header1(Header, {Record, Options ++ [send_100]});
        <<"content-length: ", CLength/binary>> ->
            % This is only used for 100 requests
            Len = list_to_integer(binary_to_list(CLength)),
            parse_header1(Header, {Record#ol_record{content_length=Len}, Options});
        <<"x-olegdb-use-by: ", Timestamp/binary>> ->
            Time = list_to_integer(binary_to_list(Timestamp)),
            parse_header1(Header, {Record#ol_record{expiration_time=Time}, Options});
        <<"content-type: ", CType/binary>> ->
            parse_header1(Header, {Record#ol_record{content_type=CType}, Options});
        _ ->
            parse_header1(Header, {Record, Options})
    end.
