% Exercício 1
% Árvore Genealógica
% Felipe Scrochio Custṕdio - 9442688

% Defina as relações de pai e mãe
pai(X,Y) :-
    filho(Y, X),
    homem(X).

mae(X,Y) :-
    filho(Y, X),
    mulher(X).

% Defina as relações homem e mulher
mulher(ana).
mulher(bia).
mulher(eva).
mulher(clo).
mulher(lia).
mulher(gal).

homem(ivo).
homem(gil).
homem(rai).
homem(ary).
homem(noe).

% Defina a relação gerou(X, Y)
% tal que X gerou Y se X é pai ou mãe de Y
gerou(X, Y) :-
    pai(X, Y);
    mae(X, Y).

% Usando as relações já existentes, defina:
% filho, filha, tio, tia, primo, prima, avô, avó
filho(X, Y) :-
    homem(X),
    gerou(Y, X).

filha(X, Y) :-
    mulher(X),
    gerou(Y, X).

tio(X, Y) :-
    homem(X),
    irmao(X, Alguem),
    gerou(Alguem, Y).

tia(X, Y) :-
    mulher(X),
    irmao(X, Alguem),
    gerou(Alguem, Y).

primo(X, Y) :-
    homem(X),
    gerou(X, Alguem),
    irmao(Alguem, Gerador),
    gerou(Gerador, Y).

prima(X, Y) :-
    mulher(X),
    gerou(X, Alguem),
    irmao(Alguem, Gerador),
    gerou(Gerador, Y).

grandma(X, Y) :-
    mulher(X),
    gerou(X, Gerador),
    gerou(Gerador, Y).

grandpa(X, Y) :-
    homem(X),
    gerou(X, Gerador),
    gerou(Gerador, Y).
