%% The contents of this file are subject to the Mozilla Public License
%% Version 1.1 (the "License"); you may not use this file except in
%% compliance with the License. You may obtain a copy of the License
%% at https://www.mozilla.org/MPL/
%%
%% Software distributed under the License is distributed on an "AS IS"
%% basis, WITHOUT WARRANTY OF ANY KIND, either express or implied. See
%% the License for the specific language governing rights and
%% limitations under the License.
%%
%% The Original Code is RabbitMQ.
%%
%% The Initial Developer of the Original Code is GoPivotal, Inc.
%% Copyright (c) 2007-2020 VMware, Inc. or its affiliates.  All rights reserved.
%%

-module(rabbit_control_helper).

-export([command/2, command/3, command/4, command_with_output/4, format_command/4]).

command(Command, Node, Args) ->
    command(Command, Node, Args, []).

command(Command, Node) ->
    command(Command, Node, [], []).

command(Command, Node, Args, Opts) ->
    case command_with_output(Command, Node, Args, Opts) of
        {ok, _} -> ok;
        ok      -> ok;
        Error   -> Error
    end.

command_with_output(Command, Node, Args, Opts) ->
    Formatted = format_command(Command, Node, Args, Opts),
    CommandResult = 'Elixir.RabbitMQCtl':exec_command(
        Formatted, fun(Output,_,_) -> Output end),
    ct:pal("Executed command ~p against node ~p~nResult: ~p~n", [Formatted, Node, CommandResult]),
    CommandResult.

format_command(Command, Node, Args, Opts) ->
    Formatted = io_lib:format("~tp ~ts ~ts",
                              [Command,
                               format_args(Args),
                               format_options([{"--node", Node} | Opts])]),
    'Elixir.OptionParser':split(iolist_to_binary(Formatted)).

format_args(Args) ->
    iolist_to_binary([ io_lib:format("~tp ", [Arg]) || Arg <- Args ]).

format_options(Opts) ->
    EffectiveOpts = [{"--script-name", "rabbitmqctl"} | Opts],
    iolist_to_binary([io_lib:format("~s=~tp ", [Key, Value])
                      || {Key, Value} <- EffectiveOpts ]).

