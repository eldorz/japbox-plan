% Create a cutting design for the pieces of a japanese box to fit a
% piece of wood of any size.

% Laughlin Dawes 8/3/2014

% Japanese toolbox design courtesy Make magazine:
% http://makezine.com/projects/make-34/japanese-toolbox/

% Code based on block-in-box fitting program from Prolog
% Programming for Artifical Intelligence 4th ed, I Bratko, Chapter 7
% Constraint Logic Programming.

% How to use...
% 1. Set the size and thickness of your wooden sheet under sheet size
% below.
%
% 2. Search can take a long time, so it is a good idea to find an
% approximate value. Do this by calling, fit(ply, your_guess, L), where
% your_guess is your estimate of box length. This will either succeed or
% fail. You can now constrain BoxLen in the first line of the fit
% function to the upper bound of your successful guesses - this will
% significantly reduce runtime.
%
% 3. Call best_fit(X). Wait a while.
% Ctrl-C & a when bored of waiting, this function may not end in any
% reasonable time. X will be your box's length, and the program will
% output the sizes and orientations of all the parts. You will still
% have to guess some of the positions of the parts as they will be
% variables. If you really want to see the constraints you can rerun
% fit(ply, X, L), but I've found the constraints to be pretty unhelpful
% on the whole.

% need to call use_module(library(clpr)). to load constraint logic
% programming library.

% proportions
y_ratio(X,Y) :-
	{Y = 0.433 * X}.
z_ratio(X,Z) :-
	{Z = 0.308 * X}.

% sheet size
sheet(ply,dim(X,Y)) :-
	X is 1200,
	Y is 596.
thickness(T) :-
	T is 18.

% width of a saw cut
cut(T) :-
	T is 4.

% representation of rectangles
%  rect(pos(X,Y), dim(A,B)) represents a rectangle of size A by B at
%  position pos(X,Y)

% rotate(Rectangle, RotatedRectangle)
%   Rotation of rectangle in X-Y plane, always aligned with X-Y axes

rotate(rect(Pos,Dim), rect(Pos,Dim)).           % zero rotation
rotate(rect(Pos,dim(A,B)), rect(Pos,dim(B,A))). % rotated by 90 deg

% inside(Rectangle1, Rectangle2): Rectangle1 completely inside
% Rectangle2

inside(rect(pos(X1,Y1), dim(Dx1,Dy1)), rect(pos(X2,Y2), dim(Dx2,Dy2))):-
	{X1 >= X2, Y1 >= Y2, X1 + Dx1 =< X2 + Dx2, Y1 + Dy1 =< Y2 + Dy2}.

% no_overlap(Rectangle1, Rectangle2): Rectangles do not overlap

no_overlap(rect(pos(X1,Y1), dim(Dx1,Dy1)), rect(pos(X2,Y2), dim(Dx2,Dy2))):-
	{X1 + Dx1 =< X2; X2 + Dx2 =< X1;  %rects left or right of each other
	 Y1 + Dy1 =< Y2; Y2 + Dy2 =< Y1}. %rects above or below each other

piece(bottom, BoxLen, dim(BoxLen,Y)) :-
	y_ratio(BoxLen,Y).
piece(lid, BoxLen, dim(A,B)) :-
	y_ratio(BoxLen,Y),
	thickness(T),
	{A >= 0,
	 A = Y - 2 * T,
	 B = 0.813 * BoxLen}.
piece(lid_brace, BoxLen, dim(A,B)) :-
	{A = 0.053 * BoxLen,
	B = 0.813 * BoxLen}.
piece(side, BoxLen, dim(BoxLen,B)) :-
	z_ratio(BoxLen,Z),
	thickness(T),
	{B >= 0,
	 B = Z - T}.
piece(end, BoxLen, dim(A,B)) :-
	y_ratio(BoxLen,Y),
	z_ratio(BoxLen,Z),
	thickness(T),
	{A >= 0,
	 A = Y - 2 * T,
	 B >= 0,
	 B = Z - T}.
piece(top_end, BoxLen, dim(Y, B)) :-
	y_ratio(BoxLen,Y),
	{B = 0.115 * BoxLen}.
piece(lid_support, BoxLen, dim(Y, B)) :-
	y_ratio(BoxLen,Y),
	{B = 0.058 * BoxLen}.
piece(grip, BoxLen, dim(A,B)) :-
	y_ratio(BoxLen,Y),
	z_ratio(BoxLen,Z),
	thickness(T),
	{A >= 0,
	 A = Y - 2 * T,
	 B = 0.188 * Z}.

piece_plus_cut(PieceName, BoxLen, dim(A1, B1)) :-
	cut(T),
	piece(PieceName, BoxLen, dim(A,B)),
	{A1 = A + T,
	B1 = B + T}.

piece_rectangle(PieceName, BoxLen, rect(Pos, Dim)) :-
	piece_plus_cut(PieceName, BoxLen, Dim0), % dimensions of piece
	rotate(rect(Pos, Dim0), rect(Pos, Dim)). % Rectangle may be rotated

fit(SheetName, BoxLen, [bottom/PieceA, lid/PieceB, side1/PieceC, side2/PieceD,
			end1/PieceE, end2/PieceF, top_end1/PieceG, top_end2/PieceH,
			lid_support1/PieceI, lid_support2/PieceJ, grip1/PieceK,
			grip2/PieceL, lid_brace/PieceM]) :-
	% modify BoxLen to provide a lower bound on your box's length. Too high
	% and fitting will fail, too low and it will take a very long time.
	{BoxLen >= 590},
	sheet(SheetName, Dim), Sheet = rect(pos(0.0,0.0), Dim),
	piece_rectangle(bottom, BoxLen, PieceA), inside(PieceA, Sheet),
	piece_rectangle(lid, BoxLen, PieceB), inside(PieceB, Sheet),
	no_overlap(PieceA, PieceB),
	piece_rectangle(side, BoxLen, PieceC), inside(PieceC, Sheet),
	no_overlap(PieceA, PieceC),
	no_overlap(PieceB, PieceC),
	piece_rectangle(side, BoxLen, PieceD), inside(PieceD, Sheet),
	no_overlap(PieceA, PieceD),
	no_overlap(PieceB, PieceD),
	no_overlap(PieceC, PieceD),
	piece_rectangle(end, BoxLen, PieceE), inside(PieceE, Sheet),
	no_overlap(PieceA, PieceE),
	no_overlap(PieceB, PieceE),
	no_overlap(PieceC, PieceE),
	no_overlap(PieceD, PieceE),
	piece_rectangle(end, BoxLen, PieceF), inside(PieceF, Sheet),
	no_overlap(PieceA, PieceF),
	no_overlap(PieceB, PieceF),
	no_overlap(PieceC, PieceF),
	no_overlap(PieceD, PieceF),
	no_overlap(PieceE, PieceF),
	piece_rectangle(top_end, BoxLen, PieceG), inside(PieceG, Sheet),
	no_overlap(PieceA, PieceG),
	no_overlap(PieceB, PieceG),
	no_overlap(PieceC, PieceG),
	no_overlap(PieceD, PieceG),
	no_overlap(PieceE, PieceG),
	no_overlap(PieceF, PieceG),
	piece_rectangle(top_end, BoxLen, PieceH), inside(PieceH,Sheet),
	no_overlap(PieceA, PieceH),
	no_overlap(PieceB, PieceH),
	no_overlap(PieceC, PieceH),
	no_overlap(PieceD, PieceH),
	no_overlap(PieceE, PieceH),
	no_overlap(PieceF, PieceH),
	no_overlap(PieceG, PieceH),
	piece_rectangle(lid_support,BoxLen, PieceI), inside(PieceI,Sheet),
	no_overlap(PieceA, PieceI),
	no_overlap(PieceB, PieceI),
	no_overlap(PieceC, PieceI),
	no_overlap(PieceD, PieceI),
	no_overlap(PieceE, PieceI),
	no_overlap(PieceF, PieceI),
	no_overlap(PieceG, PieceI),
	no_overlap(PieceH, PieceI),
	piece_rectangle(lid_support,BoxLen, PieceJ), inside(PieceJ,Sheet),
	no_overlap(PieceA, PieceJ),
	no_overlap(PieceB, PieceJ),
	no_overlap(PieceC, PieceJ),
	no_overlap(PieceD, PieceJ),
	no_overlap(PieceE, PieceJ),
	no_overlap(PieceF, PieceJ),
	no_overlap(PieceG, PieceJ),
	no_overlap(PieceH, PieceJ),
	no_overlap(PieceI, PieceJ),
	piece_rectangle(grip,BoxLen, PieceK), inside(PieceK,Sheet),
	no_overlap(PieceA, PieceK),
	no_overlap(PieceB, PieceK),
	no_overlap(PieceC, PieceK),
	no_overlap(PieceD, PieceK),
	no_overlap(PieceE, PieceK),
	no_overlap(PieceF, PieceK),
	no_overlap(PieceG, PieceK),
	no_overlap(PieceH, PieceK),
	no_overlap(PieceI, PieceK),
	no_overlap(PieceJ, PieceK),
	piece_rectangle(grip,BoxLen, PieceL), inside(PieceL,Sheet),
	no_overlap(PieceA, PieceL),
	no_overlap(PieceB, PieceL),
	no_overlap(PieceC, PieceL),
	no_overlap(PieceD, PieceL),
	no_overlap(PieceE, PieceL),
	no_overlap(PieceF, PieceL),
	no_overlap(PieceG, PieceL),
	no_overlap(PieceH, PieceL),
	no_overlap(PieceI, PieceL),
	no_overlap(PieceJ, PieceL),
	no_overlap(PieceK, PieceL),
	piece_rectangle(lid_brace,BoxLen, PieceM), inside(PieceM,Sheet),
	no_overlap(PieceA, PieceM),
	no_overlap(PieceB, PieceM),
	no_overlap(PieceC, PieceM),
	no_overlap(PieceD, PieceM),
	no_overlap(PieceE, PieceM),
	no_overlap(PieceF, PieceM),
	no_overlap(PieceG, PieceM),
	no_overlap(PieceH, PieceM),
	no_overlap(PieceI, PieceM),
	no_overlap(PieceJ, PieceM),
	no_overlap(PieceK, PieceM),
	no_overlap(PieceL, PieceM),
	maximize(BoxLen).

best_fit(MaxLen) :-
	var(MaxLen), !, best_fit(0.0)
	;
	fit(ply, BoxLen, L),
	BoxLen > MaxLen, !, print(BoxLen), nl, writelist(L), nl, best_fit(BoxLen)
	;
	best_fit(MaxLen).

writelist([]).
writelist([X|L]):-
	X = PieceName/rect(pos(A,B), dim(C,D)),
	write(PieceName),
	write(': pos('),
	write_if_num(A),
	write(','),
	write_if_num(B),
	write(') dim('),
	cut(Cut),
	format('~0f',C - Cut),
	write(','),
	format('~0f',D - Cut),
	write(')'),
	nl,
	writelist(L).

write_if_num(X) :-
	number(X), !, format('~0f',X)
	;
	write('*').





