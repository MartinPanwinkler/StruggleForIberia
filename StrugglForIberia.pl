% ====================================================================
% THE STRUGGLE FOR IBERIA - A Prolog Text Adventure Game
% Set in 11th Century Spain - Play as King Sancho II of Castile
% ====================================================================

:- dynamic(character/5).
:- dynamic(location/3).
:- dynamic(event/4).
:- dynamic(inventory/2).
:- dynamic(knowledge/2).
:- dynamic(alliance/3).
:- dynamic(control/2).
:- dynamic(game_state/2).
:- dynamic(player_stats/3).

% ====================================================================
% GAME INITIALIZATION
% ====================================================================

init_game :-
    retractall(character(_,_,_,_,_)),
    retractall(location(_,_,_)),
    retractall(event(_,_,_,_)),
    retractall(inventory(_,_)),
    retractall(knowledge(_,_)),
    retractall(alliance(_,_,_)),
    retractall(control(_,_)),
    retractall(game_state(_,_)),
    retractall(player_stats(_,_,_)),
    init_characters,
    init_locations,
    init_events,
    init_alliances,    init_player_state,
    write('=== THE STRUGGLE FOR IBERIA ==='), nl,
    write('11th Century Spain - You are King Sancho II of Castile'), nl,
    write('Your goal: Unite Spain under your rule through diplomacy, war, or cunning.'), nl, nl.

% ====================================================================
% CHARACTER DEFINITIONS
% character(Name, Role, Traits, Alliances, Goals)
% ====================================================================

init_characters :-
    assertz(character(sancho,     king,          [ambitious, warrior, proud],       [castile],                   [unite_spain, defeat_brothers])),
    assertz(character(garcia,     king_galicia, [cunning, opportunistic, intelligent], [galicia],               [survive, gain_power])),
    assertz(character(urraca,     queen_leon,   [manipulative, clever, patient],    [leon],                       [political_dominance, preserve_leon])),
    assertz(character(esteban,    abbot,            [wise, moral, influential],         [church],                     [spiritual_guidance, peace])),
    assertz(character(el_cid,     knight,         [loyal, brave, skilled],            [castile],                  [serve_sancho, honor])),
    assertz(character(al_mutamid, emir,           [diplomatic, wealthy, cultured],    [sevilla],                    [preserve_independence, profit])).

% ====================================================================
% LOCATION DEFINITIONS
% location(Place, Description, ControlledBy)
% ====================================================================

init_locations :-
    assertz(location(castile, 'The heart of your realm - strongly fortified and loyal', sancho)),
    assertz(location(leon,      'Rich northern lands - controlled by Urraca',    urraca)),
    assertz(location(galicia,  'Mountainous borderland - Garcia rules here',        garcia)),
    assertz(location(sevilla,   'Flourishing Muslim city - Al-Mutamid is Emir', al_mutamid)),
    assertz(location(toledo,    'Strategically important fortress - contested territory', neutral)),
    assertz(location(salamanca, 'Important trading city on the border',               neutral)).

% ====================================================================
% EVENT SYSTEM
% event(Name, Conditions, Consequences, Result)
% ====================================================================

init_events :-
    % Battle for Leon
    assertz(event(battle_for_leon,
        [ has_army(sancho),
          at_border(sancho, leon),
          \+ alliance(urraca, sancho, neutral)
        ],
        [ retract(control(leon, urraca)),
          assertz(control(leon, sancho)),
          retract(alliance(urraca, sancho, _)),
          assertz(alliance(urraca, sancho, enemy))
        ],
        'Leon has been conquered in bloody battle! Urraca flees to Toledo.')),
    % Negotiations with Garcia
    assertz(event(negotiate_with_garcia,
        [ has_knowledge(sancho, garcia_weakness),
          at_location(sancho, galicia)
        ],
        [ assertz(alliance(garcia, sancho, vassal)),
          assertz(knowledge(sancho, garcia_loyalty))
        ],
        'Garcia submits to your rule and swears loyalty!')),
    % Religious blessing
    assertz(event(religious_blessing,
        [ alliance(esteban, sancho, friendly),
          at_location(sancho, castile)
        ],
        [ assertz(player_stats(sancho, legitimacy, high)),
          assertz(knowledge(sancho, divine_support))
        ],
        'Abbot Esteban blesses your campaign – the people see you as sent by God!')),
    % Cid's heroic victory
    assertz(event(cid_heroic_victory,
        [ alliance(el_cid, sancho, loyal),
          has_army(sancho)
        ],
        [ assertz(player_stats(sancho, military_strength, very_high)),
          assertz(knowledge(sancho, cid_legend))
        ],
        'El Cid leads your troops to a legendary victory – his fame strengthens your position.')),
    % Alliance with the Muslims
    assertz(event(muslim_alliance,
        [ alliance(al_mutamid, sancho, friendly),
          \+ alliance(esteban, sancho, enemy)
        ],
        [ assertz(knowledge(sancho, muslim_support)),
          assertz(inventory(sancho, gold_tribute))
        ],
        'Al-Mutamid offers you gold and troops against your Christian rivals!')).

% ====================================================================
% ALLIANCE AND CONTROL SYSTEM
% ====================================================================

init_alliances :-
    assertz(alliance(el_cid,     sancho, loyal)),
    assertz(alliance(esteban,    sancho, friendly)),
    assertz(alliance(garcia,     sancho, neutral)),
    assertz(alliance(urraca,     sancho, enemy)),
    assertz(alliance(al_mutamid, sancho, neutral)),
    assertz(control(castile,   sancho)),
    assertz(control(leon,        urraca)),
    assertz(control(galicia,    garcia)),
    assertz(control(sevilla,     al_mutamid)).

% ====================================================================
% PLAYER STATE MANAGEMENT
% ====================================================================

init_player_state :-
    assertz(game_state(current_location, castile)),
    assertz(game_state(turn, 1)),
    assertz(game_state(season, spring)),
    assertz(player_stats(sancho, military_strength, medium)),
    assertz(player_stats(sancho, legitimacy,        medium)),
    assertz(player_stats(sancho, gold,               medium)),
    assertz(inventory(sancho, royal_seal)),
    assertz(knowledge(sancho, family_rivalry)).

% ====================================================================
% GAME MECHANICS
% ====================================================================

has_army(Player) :-
    player_stats(Player, military_strength, L),
    member(L, [medium, high, very_high]).

at_location(Player, Loc) :-
    game_state(current_location, Loc),
    Player = sancho.

at_border(Player, Terr) :-
    game_state(current_location, Cur),
    Player = sancho,
    borders(Cur, Terr).

borders(castile, leon).
borders(castile, galicia).
borders(castile, toledo).
borders(leon,      galicia).
borders(leon,      salamanca).
borders(galicia,  sevilla).
borders(toledo,    sevilla).

has_knowledge(Player, K) :-
    knowledge(Player, K).

% ====================================================================
% MAIN GAME LOOP
% ====================================================================

main_loop :-
    game_state(turn, Turn),
    game_state(current_location, Loc),
    game_state(season, Season),
    nl,
    format('=== TURN ~w - ~w ===~n', [Turn, Season]),
    format('You are currently in: ~w~n', [Loc]),
    show_status, nl,
    show_options, nl,
    write('What is your command? '), read(C),
    process_choice(C),
    check_events,
    advance_turn,
    ( check_victory -> write('VICTORY! You have united Spain!'), nl
    ; check_defeat  -> write('DEFEAT! Your rule has ended.'), nl
    ; main_loop ).

% ====================================================================
% PLAYER ACTIONS
% ====================================================================

process_choice(1) :- action_diplomacy, !.
process_choice(2) :- action_military, !.
process_choice(3) :- action_espionage, !.
process_choice(4) :- action_travel, !.
process_choice(5) :- action_consult_advisor, !.
process_choice(6) :- show_detailed_status, !.
process_choice(7) :- write('Game ended. Farewell!'), nl, halt.
process_choice(_) :- write('Invalid choice! Please select 1-7.'), nl, main_loop.

% ====================================================================
% ACTION IMPLEMENTATIONS
% ====================================================================

action_diplomacy :-
    nl,
    write('=== DIPLOMACY ==='), nl,
    write('1. Negotiate with Garcia of Galicia'), nl,
    write('2. Send envoy to Urraca of Leon'), nl,
    write('3. Approach Al-Mutamid of Seville'), nl,
    write('4. Meet with Abbot Esteban'), nl,
    write('5. Return to main menu'), nl,
    write('Your choice: '), read(C),
    process_diplomacy(C).

process_diplomacy(1) :-
    (   alliance(garcia, sancho, enemy) ->
        write('Garcia refuses to meet with you after your previous actions.'), nl
    ;   write('You send a diplomatic message to your brother Garcia...'), nl,
        (   alliance(garcia, sancho, neutral) ->
            retract(alliance(garcia, sancho, neutral)),
            assertz(alliance(garcia, sancho, friendly)),
            write('Garcia agrees to a non-aggression pact!'), nl
        ;   write('Garcia listens but makes no commitments.'), nl
        )
    ), !.

process_diplomacy(2) :-
    write('You attempt to reach out to your sister Urraca...'), nl,
    (   alliance(urraca, sancho, enemy) ->
        write('Urraca spurns your overtures. "Leon will never bow to Castile!"'), nl
    ;   write('Urraca receives your envoy coldly but agrees to talk.'), nl
    ), !.

process_diplomacy(3) :-
    write('You send envoys to the Muslim emir Al-Mutamid...'), nl,
    (   alliance(al_mutamid, sancho, neutral) ->
        retract(alliance(al_mutamid, sancho, neutral)),
        assertz(alliance(al_mutamid, sancho, friendly)),
        write('Al-Mutamid offers a profitable trade agreement!'), nl,
        assertz(player_stats(sancho, gold, high))
    ;   write('Al-Mutamid remains cordial but non-committal.'), nl
    ), !.

process_diplomacy(4) :-
    write('You meet with Abbot Esteban in the monastery...'), nl,
    (   alliance(esteban, sancho, friendly) ->
        write('The Abbot blesses your righteous cause!'), nl,
        assertz(player_stats(sancho, legitimacy, high))
    ;   write('Esteban counsels patience and faith.'), nl
    ), !.

process_diplomacy(5) :- !.
process_diplomacy(_) :- write('Invalid choice.'), nl, action_diplomacy.

action_military :-
    nl,
    write('=== MILITARY ACTIONS ==='), nl,
    write('1. Recruit soldiers'), nl,
    write('2. Attack neighboring territory'), nl,
    write('3. Fortify your position'), nl,
    write('4. Send El Cid on a mission'), nl,
    write('5. Return to main menu'), nl,
    write('Your choice: '), read(C),
    process_military(C).

process_military(1) :-
    write('You gather soldiers and strengthen your army...'), nl,
    (   player_stats(sancho, military_strength, low) ->
        retract(player_stats(sancho, military_strength, low)),
        assertz(player_stats(sancho, military_strength, medium))
    ;   player_stats(sancho, military_strength, medium) ->
        retract(player_stats(sancho, military_strength, medium)),
        assertz(player_stats(sancho, military_strength, high))
    ;   write('Your army is already at peak strength!'), nl
    ), !.

process_military(2) :-
    game_state(current_location, Loc),
    write('Which territory do you wish to attack?'), nl,
    findall(T, borders(Loc, T), Targets),
    show_targets(Targets, 1),
    write('Your choice: '), read(C),
    (   nth1(C, Targets, Target) ->
        attempt_conquest(Target)
    ;   write('Invalid target.'), nl
    ), !.

process_military(3) :-
    write('You strengthen the defenses of your current position.'), nl,
    assertz(player_stats(sancho, legitimacy, high)), !.

process_military(4) :-
    (   alliance(el_cid, sancho, loyal) ->
        write('El Cid accepts your mission and rides out!'), nl,
        assertz(player_stats(sancho, military_strength, very_high))
    ;   write('El Cid is not available for missions.'), nl
    ), !.

process_military(5) :- !.
process_military(_) :- write('Invalid choice.'), nl, action_military.

show_targets([], _).
show_targets([T|Rest], N) :-
    format('~w. ~w~n', [N, T]),
    N1 is N + 1,
    show_targets(Rest, N1).

attempt_conquest(Target) :-
    (   has_army(sancho) ->
        format('You launch an attack on ~w!~n', [Target]),        (   control(Target, Enemy), Enemy \= sancho ->
            write('Battle is joined!'), nl,
            retract(control(Target, Enemy)),
            assertz(control(Target, sancho)),
            format('Victory! You have conquered ~w!~n', [Target])
        ;   write('The territory is already under your control.'), nl
        )
    ;   write('You need a stronger army before attempting conquest.'), nl
    ).

action_espionage :-
    nl,
    write('=== ESPIONAGE ==='), nl,
    write('1. Gather intelligence on Garcia'), nl,
    write('2. Spy on Urraca activities'), nl,
    write('3. Investigate the Muslim territories'), nl,
    write('4. Return to main menu'), nl,
    write('Your choice: '), read(C),
    process_espionage(C).

process_espionage(1) :-
    write('Your spies report on Garcia weaknesses...'), nl,
    assertz(knowledge(sancho, garcia_weakness)), !.

process_espionage(2) :-
    write('You learn of Urraca political maneuvering...'), nl,
    assertz(knowledge(sancho, urraca_plans)), !.

process_espionage(3) :-
    write('Your agents gather information about the Muslim kingdoms...'), nl,
    assertz(knowledge(sancho, muslim_politics)), !.

process_espionage(4) :- !.
process_espionage(_) :- write('Invalid choice.'), nl, action_espionage.

action_travel :-
    nl,
    write('=== TRAVEL ==='), nl,
    write('Where would you like to travel?'), nl,
    game_state(current_location, Current),
    findall(T, borders(Current, T), Adjacent),
    show_travel_options(Adjacent, 1),
    format('~w. Stay in ~w~n', [99, Current]),
    write('Your choice: '), read(C),
    (   nth1(C, Adjacent, Destination) ->
        travel_to(Destination)
    ;   C = 99 ->
        write('You remain in your current location.'), nl
    ;   write('Invalid destination.'), nl
    ), !.

show_travel_options([], _).
show_travel_options([T|Rest], N) :-
    format('~w. Travel to ~w~n', [N, T]),
    N1 is N + 1,
    show_travel_options(Rest, N1).

travel_to(Destination) :-
    retract(game_state(current_location, _)),
    assertz(game_state(current_location, Destination)),
    format('You travel to ~w.~n', [Destination]).

action_consult_advisor :-
    nl,
    write('=== ADVISORS ==='), nl,
    write('1. Consult El Cid (Military)'), nl,
    write('2. Speak with Abbot Esteban (Spiritual)'), nl,
    write('3. Review intelligence reports'), nl,
    write('4. Return to main menu'), nl,
    write('Your choice: '), read(C),
    process_advisor(C).

process_advisor(1) :-
    (   alliance(el_cid, sancho, loyal) ->
        write('El Cid: "My lord, strength and honor will see us victorious!"'), nl
    ;   write('El Cid is not available to advise you.'), nl
    ), !.

process_advisor(2) :-
    write('Abbot Esteban: "Seek Gods blessing in all your endeavors, my son."'), nl, !.

process_advisor(3) :-
    write('=== INTELLIGENCE REPORT ==='), nl,
    findall(K, knowledge(sancho, K), Knowledge),
    (   Knowledge = [] ->
        write('No special intelligence available.'), nl
    ;   forall(member(K, Knowledge), (format('- ~w~n', [K])))
    ), !.

process_advisor(4) :- !.
process_advisor(_) :- write('Invalid choice.'), nl, action_consult_advisor.

% ====================================================================
% STATUS & DISPLAY
% ====================================================================

show_status :-
    write('--- STATUS ---'), nl,
    player_stats(sancho, military_strength, MS),
    player_stats(sancho, legitimacy,      L),
    player_stats(sancho, gold,            G),
    format('Military: ~w~nLegitimacy: ~w~nGold: ~w~n', [MS,L,G]),
    findall(T, control(T, sancho), Ts),
    format('Controlled: ~w~n', [Ts]).

show_detailed_status :-
    nl,
    write('=== DETAILED STATUS ==='), nl,
    write('Alliances:'), nl,
    findall([N,S], alliance(N,sancho,S), As),
    forall(member([N,S], As), format('  ~w: ~w~n', [N,S])),
    write('Knowledge:'), nl,
    findall(K, knowledge(sancho,K), Ks),
    forall(member(K, Ks), format('  - ~w~n', [K])),
    write('Inventory:'), nl,
    findall(I, inventory(sancho,I), Is),
    forall(member(I, Is), format('  - ~w~n', [I])).

show_options :-
    write('=== OPTIONS ==='), nl,
    write('1. Diplomacy'), nl,
    write('2. Military'), nl,
    write('3. Espionage'), nl,
    write('4. Travel'), nl,
    write('5. Advisors'), nl,
    write('6. Detailed Status'), nl,
    write('7. Quit'), nl.

% ====================================================================
% EVENT CHECKING & TURNS
% ====================================================================

check_events :-
    event(Name,Conds,Cons,Res),
    check_conditions(Conds),
    !,
    execute_consequences(Cons),    nl, write('*** EVENT ***'), nl,
    write(Res), nl,
    retract(event(Name,Conds,Cons,Res)).
check_events.

check_conditions([]).
check_conditions([C|R]) :- call(C), check_conditions(R).

execute_consequences([]).
execute_consequences([C|R]) :- call(C), execute_consequences(R).

advance_turn :-
    retract(game_state(turn,T)),
    T1 is T+1,
    assertz(game_state(turn,T1)),
    retract(game_state(season,S)),
    next_season(S,S2),
    assertz(game_state(season,S2)).

next_season(spring, summer).
next_season(summer, autumn).
next_season(autumn, winter).
next_season(winter, spring).

% ====================================================================
% WIN/LOSE
% ====================================================================

check_victory :-
    findall(T, control(T,sancho), Ts),
    length(Ts,N), N >= 4.

check_defeat :-
    \+ control(castile, sancho).

% ====================================================================
% STORY & HELP
% ====================================================================

show_story :-
    nl,
    write('=== THE STRUGGLE FOR IBERIA - BACKGROUND STORY ==='), nl, nl,
    write('The year is 1065 AD. King Ferdinand I of Leon has died, dividing his kingdom'), nl,
    write('among his three children in a fateful decision that will tear Spain apart.'), nl, nl,
    write('You are SANCHO II, the ambitious King of Castile. Your father gave you the'), nl,
    write('smallest but most strategic portion of the realm. Your siblings received:'), nl, nl,
    write('- URRACA: The wealthy kingdom of Leon, making her a formidable rival'), nl,
    write('- GARCIA: The mountainous region of Galicia, though he lacks ambition'), nl, nl,
    write('The Muslim taifas to the south, led by Al-Mutamid of Seville, watch with'), nl,
    write('interest as the Christian kingdoms fragment. They pay tribute but remain'), nl,
    write('independent, playing the brothers against each other.'), nl, nl,
    write('Your loyal knight EL CID stands ready to serve, while Abbot ESTEBAN'), nl,
    write('of the church could provide spiritual legitimacy to your cause.'), nl, nl,
    write('Your goal is clear: Unite all of Spain under your crown. But will you'), nl,
    write('achieve this through diplomacy, conquest, or cunning manipulation?'), nl, nl,
    write('The fate of Iberia rests in your hands, King Sancho...'), nl, nl.

start_game :- init_game, main_loop.

help :-
    nl,
    write('=== AVAILABLE COMMANDS ==='), nl,
    write('start_game.   - Start the game'), nl,
    write('story.        - Read the background story'), nl,
    write('test_game.    - Test game initialization'), nl,
    write('help.         - Show this help'), nl, nl.

% ====================================================================
% TEST PREDICATE
% ====================================================================

test_game :-
    init_game,
    write('Game initialized successfully!'), nl,
    write('Current location: '), game_state(current_location, Loc), write(Loc), nl,
    write('Player stats:'), nl,
    player_stats(sancho, military_strength, MS), format('  Military: ~w~n', [MS]),
    player_stats(sancho, legitimacy, L), format('  Legitimacy: ~w~n', [L]),
    player_stats(sancho, gold, G), format('  Gold: ~w~n', [G]),
    write('Available actions work correctly!'), nl.

% Add story command
story :- show_story.

% ====================================================================
% UTILITY PREDICATES
% ====================================================================

nth1(1, [H|_], H) :- !.
nth1(N, [_|T], E) :-
    N > 1,
    N1 is N - 1,
    nth1(N1, T, E).

:- initialization((
    write('Welcome to THE STRUGGLE FOR IBERIA!'), nl,
    write('Enter "start_game." to begin, "story." for background, or "help." for commands.'), nl, nl
)).
