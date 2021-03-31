INSERT INTO ALUNO VALUES (1777,	'Carlos Sousa', 	'Rua das Tijoleiras', 	to_date('26-02-1997', 'dd-mm-yyyy'), NULL, NULL, 2, 'C1777');
INSERT INTO ALUNO VALUES (1888,	'Susana Costa',		'Rua da Beleza',		to_date('29-08-1984', 'dd-mm-yyyy'), NULL, NULL, 1, 'S1888');
INSERT INTO ALUNO VALUES (1999,	'Filipe da Silva',	'Av. Vidal Pinheiro',	to_date('01-01-1995', 'dd-mm-yyyy'), 'C', to_date('05-02-2018', 'dd-mm-yyyy'), 0, 'F1999');


INSERT INTO Exame VALUES (10809, 'Estadio da cidade', to_date('03-12-2020', 'dd-mm-yyyy'),	'C');
INSERT INTO Exame VALUES (10900, 'Estadio da cidade', to_date('04-12-2020', 'dd-mm-yyyy'),	'A');
INSERT INTO Exame VALUES (10901, 'Escola', to_date('01-01-2021', 'dd-mm-yyyy'),	'C');
INSERT INTO Exame VALUES (10902, 'Estadio da cidade', to_date('07-02-2021', 'dd-mm-yyyy'),	'A');
INSERT INTO Exame VALUES (10903, 'Escola', to_date('09-02-2021', 'dd-mm-yyyy'),	'A');
INSERT INTO Exame VALUES (10904, 'Centro de Testes Automóveis', to_date('12-03-2021', 'dd-mm-yyyy'),	'B');
INSERT INTO Exame VALUES (10905, 'Centro de Testes Automóveis', to_date('13-03-2021', 'dd-mm-yyyy'),	'A');
INSERT INTO Exame VALUES (10906, 'Centro de Testes Automóveis', to_date('01-04-2021', 'dd-mm-yyyy'),	'B');
INSERT INTO Exame VALUES (10907, 'Estadio da cidade', to_date('10-04-2021', 'dd-mm-yyyy'),	'B');


INSERT INTO Inscricao VALUES (7089, to_date('08-11-2020', 'dd-mm-yyyy'), 'S',	to_date('08-12-2020', 'dd-mm-yyyy'), 'C',	1999,	10901,	'A');
INSERT INTO Inscricao VALUES (7090, to_date('01-12-2020', 'dd-mm-yyyy'), 'S',	to_date('04-01-2021', 'dd-mm-yyyy'), 'A',	1777,	10900,	'R');
INSERT INTO Inscricao VALUES (7091, to_date('08-12-2020', 'dd-mm-yyyy'), 'S',	to_date('04-01-2021', 'dd-mm-yyyy'), 'C',	1888,	10901,	'R');
INSERT INTO Inscricao VALUES (7092, to_date('10-01-2021', 'dd-mm-yyyy'), 'N',	NULL,								 'B',	1999,	NULL,	NULL);
INSERT INTO Inscricao VALUES (7093, to_date('11-01-2021', 'dd-mm-yyyy'), 'S',	to_date('12-01-2021', 'dd-mm-yyyy'), 'A',	1777,	10902,	'R');
INSERT INTO Inscricao VALUES (7094, to_date('10-01-2021', 'dd-mm-yyyy'), 'S',	to_date('20-01-2021', 'dd-mm-yyyy'), 'A',	1777,	10903,	NULL);
INSERT INTO Inscricao VALUES (7095, to_date('08-02-2021', 'dd-mm-yyyy'), 'N',	NULL,                                'D',	1777,	NULL,	NULL);
commit;
