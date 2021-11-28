:- dynamic(sizeInventory/1).
:- dynamic(currInventory/1).

% DECLARE VALUE %
maxInventory(100).
currInventory([]).

inventory :-
    write('What do you want to do?\n'),
    write('1. Use Item\n'),
    write('2. Throw Item\n'),
    write('3. Show Inventory\n'),
    write('4. exit\n'),
    write('Enter command: '), read(Input), nl,
    (
    Input == 1 -> 
    showUseableInventory,
    write('Which item do you want to use?\n'),
    write('Enter command: '), read(InputUse), nl;

    Input == 2->
    showRemoveableInventory,
    write('\nWhat do you want to throw?'),
    read(InputThrow), nl,
    currInventory(Inventory),
    (member(InputThrow, Inventory) -> 
    itemName(InputThrow, ItemThrowName),
    cntItemInventory(CntThrow),
    format('You have ~w ~w. How many do you want to throw?\n', [CntThrow, ItemThrowName]),
    read(InputManyThrow), nl,
    (InputManyThrow > CntThrow ->
    format('You don’t have enough ~w. Cancelling…\n', [ItemThrowName]);
    throwItem(InputThrow, InputManyThrow),
    format('You threw away ~w ~w.\n', [InputManyThrow, ItemThrowName])
    );
    format('You don\'t have ~w in your inventory.\n', [InputThrow])
    ), !.

    );

% ADD ITEM TO INVENTORY %
addItem(Item) :-
    sizeInventory(SizeInventory),
    maxInventory(MaxInventory),
    (SizeInventory == MaxInventory -> !, write('Your inventory is full.'), fail;
    currInventory(CurrInventory),
    append(CurrInventory, [Item], NewInventory),
    retractall(currInventory(_)),
    asserta(currInventory(NewInventory)),!).

addItem(Item) :-
    currInventory(CurrInventory),
    append(CurrInventory, [Item], NewInventory),
    retractall(currInventory(_)),
    asserta(currInventory(NewInventory)),!.

addItem(_,0) :- !.

addItem(Item, Amount) :-
    addItem(Item),
    NewAmount is (Amount - 1),
    addItem(Item, NewAmount).

% COUNT SPECIFIC ITEM IN INVENTORY %
cntItemInventory(_,[],0).

cntItemInventory(H,[H|T],N) :- cntItemInventory(H,T,N1), N is 1 + N1, !.

cntItemInventory(H,[_|T],N) :- cntItemInventory(H,T,N1), N is N1, !.

% COUNT SIZE OF INVENTORY %
cntInventory([], 0).

cntInventory([_|T], Count) :-
    cntInventory(T, NewCount),
    Count is (NewCount + 1),!.

sizeInventory(SizeInventory) :-
    currInventory(Inventory),
    cntInventory(Inventory,SizeInventory),!.

% PRINT INVENTORY %
printInventory([]) :- !.

printInventory([H|T]) :-
    currInventory(Inventory),
    item(Category, H),
    (Category == 'animal' -> !;
    cntItemInventory(H, Inventory, Quantity),
    itemName(H, ItemName)
    (
    Quantity == 1 -> format('~w ~w\n',[Quantity, ItemName])), !;
    format('~w ~ws\n',[Quantity, ItemName])),!
    ),
    printInventory(T), !.

% SHOW INVENTORY %
showInventory :-
    currInventory(Inventory),
    (Inventory = [],
    write('Your inventory is empty\n'),!;
    maxInventory(MaxInventory),
    sizeInventory(SizeInventory),
    format('Your inventory (~w / ~w)\n',[SizeInventory, MaxInventory]),
    sort(Inventory),
    printInventory(Inventory),! 
    ).

showUseableInventory :-
    currInventory(Inventory),
    (Inventory = [],
    write('Your inventory is empty\n'),!;
    maxInventory(MaxInventory),
    sizeInventory(SizeInventory),
    format('Your inventory (~w / ~w)\n',[SizeInventory, MaxInventory]),
    sort(Inventory),
    printInventory(Inventory),! 
    ).

showRemoveableInventory :-
    currInventory(Inventory),
    (Inventory = [],
    write('Your inventory is empty\n'),!;
    write('Your inventory\n'),
    sort(Inventory),
    printInventory(Inventory),! 
    ).

% USE ITEM FROM INVENTORY %
useItemInventory(Item) :- 
    currInventory(Inventory),
    itemName(Item, ItemName),
    \+ member(Item,Inventory), !, format('There is no ~w in your inventory!\n', [ItemName]), fail. 

useItemInventory(Item) :-
    currInventory(Inventory),
    retractall(currInventory(_)),
    select(Item,Inventory, NewInventory),
    asserta(currInventory(NewInventory)),!.

% THROW ITEM FROM INVENTORY %
throwItem(Item) :- 
    currInventory(Inventory),
    \+ member(Item, Inventory), !, 
    itemName(Item, ItemName),
    format('There is no ~w in your inventory!\n', [ItemName]), fail.


throwItem(Item) :-
    currInventory(Inventory),
    retractall(currInventory(_)),
    select(Item, Inventory, NewInventory),
    asserta(currInventory(NewInventory)),!.

throwItem(_, 0) :- !.

throwItem(Item, Amount) :- 
    currInventory(Inventory),
    \+ member(Item, Inventory), !, 
    itemName(Item, ItemName),
    format('There is no ~w in your inventory!\n', [ItemName]), fail. 

throwItem(Item, Amount) :- 
    currInventory(Inventory),
    cntItemInventory(Item, Inventory, Quantity),
    itemName(Item, ItemName),
    (Quantity < Amount -> !, format('There is only ~w ~w in inventory!\n', [Quantity, ItemName]), fail;
    retractall(currInventory(_)),
    select(Item, Inventory, NewInventory),
    asserta(currInventory(NewInventory)),
    NewAmount is Amount - 1,
    throwItem(Item, NewAmount),!).