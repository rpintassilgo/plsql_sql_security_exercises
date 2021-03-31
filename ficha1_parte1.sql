-- FICHA 1 - PARTE 1


-- EXERCICIO 1
-- a)

SYS AS SYSDBA
START E:\aulas\Ficha01_users.sql

--describe
DESC DBA_USERS


--Verificar informação dos utilizadores que acabámos de criar
SELECT username, created
FROM DBA_USERS
WHERE TO_CHAR(SYSDATE, 'DD-MON-YYYY') = TO_CHAR(created, 'DD-MON-YYYY');


-- b)
conn rep_f1/rep
--ERRO - ver no sql plus o erro que aparece, falta de privilégio. O sys dá-lho

CONN / AS SYSDBA
GRANT create session TO rep_f1
GRANT create table To rep_f1 -- permite eliminar, criar tabelas, entre outras funcionalidades

--vistas para obter informação
session_privs 
session_roles
user_sys_privs

conn rep_f1/rep
@ e:\aulas\ficha01_tabelas.sql

SELECT table_name FROM user_tables; 

--Prefixos que precisamos saber 
DBA_    --  -> vistas para serem acedidas pelo admin
ALL_    
USER_   --  -> vistas para serem acedidas pelos utilizadores

-- c)
conn rep_f1/rep
@ e:\aulas\ficha01_dados.sql

--Visualizar estrutura e dados de todas as tabelas
DESC aluno
SELECT * FROM aluno;
DESC exame
SELECT * FROM exame;
DESC inscricao
SELECT * FROM inscricao;

-- set linesize 100


-- EXERCICIO 2

--a) Apresentar o código e a data das inscrições com exames a realizar 
--   no ano atual considerando apenas uma determinada categoria a ser pedida ao utilizador.


--b) Apresentar o nome dos alunos e a data em que cada um obteve aprovação na categoria C.
CONN REP_F1/rep
SELECT A.NOME,E.DATA
FROM ALUNO A JOIN INSCRICAO I ON A.BI=I.BI_ALUNO
JOIN EXAME E ON I.ID_EXAME=E.ID
WHERE UPPER(I.CATEGORIA)='C' AND UPPER(I.RESULTADO_EXAME)='A';
-- c) Apresentar o bi, o nome do aluno e a idade que cada aluno 
--    tinha na data em que obteve aprovação na última categoria.
SELECT A.BI,A.NOME,
TRUNC(MONTHS_BETWEEN(E.DATA,A.DATA_NASC)/12) AS "idade"
FROM ALUNO A JOIN INSCRICAO I ON A.BI=I.BI_ALUNO
JOIN EXAME E ON I.ID_EXAME=E.ID
WHERE E.CATEGORIA=A.ULT_CATEG_OBTIDA AND UPPER(I.RESULTADO_EXAME)='A';
-- a funcao trunc remove uma casa, não arredonda. Sem especificar
-- o segundo parametro (exemplo: TRUNC(15.79,1)=15.7), a funcao trunc
-- dá trunc À unidade. Ideal para esta situacao, pois queremos representar
-- a idade.


-- d) Apresentar para cada categoria, quantos dias passam (em média) 
--    desde a data da inscrição até à data do pagamento da inscrição. 
--    A consulta deve mostrar primeiro as categorias com valor médio mais alto.
SELECT categoria, 
NVL(TO_CHAR(AVG(data_pagamento - data_insc)),'AINDA NAO FOI PAGO')
AS "NUMERO DE DIAS"
FROM INSCRICAO
GROUP BY categoria
ORDER BY 2 DESC;
--e) Apresentar o bi e o nome dos alunos com exame 
--   marcado para a categoria A e que já reprovaram anteriormente
--   mais que uma vez nesta categoria.
SELECT DISTINCT A.BI,A.NOME
FROM ALUNO A JOIN INSCRICAO I ON A.BI=I.BI_ALUNO
WHERE UPPER(I.CATEGORIA)='A' AND A.TOTAL_REPROVACOES>1;






-- exercicio 3
--a)
conn / as sysdba

SELECT username
FROM rep_f1.aluno
WHERE username NOT IN (SELECT username FROM dba_users); --todos os utilizadores que estão na base de dados
--A table aluno existe na conta do rep_f1 náo no sys, logo faz-se rep_f1.aluno

CREATE USER F1999 IDENTIFIED BY F1999; -- nome e password

--b)
conn F1999/F1999 -- ainda não tem permissão para criar sessão

-- exercicio 4

CONN / AS SYSDBA

-- privilégio de sistema
desc dba_sys_privs

select grantee, privilege from dba_sys_privs
where grantee in (select username from rep_f1.aluno);
-- não existem utilizadores da escola de conducao com priv de sistema

-- privilégio de objeto
select privilege from dba_tab_privs
where grantee in (select username from rep_f1.aluno);
-- não existem utilizadores da ... com priv de objeto

-- privilégio por roles
select granted_role from dba_role_privs
where grantee in (select username from rep_f1.aluno);
-- não existem utilizadores da .. com roles associadas


-- exercicio 5
--não considerar privilégios representados com setas a verde

-- 1. verificar se existem os roles
select role from dba_roles
where upper(role) in ('ROLE_ALUNO','CONNECT');
-- a role CONNECT já existe


-- 2. criar caso necessário
create role role_aluno;

-- verificar a role em falta após a sua criação
select role from dba_roles
where upper(role) in ('ROLE_ALUNO','CONNECT');

-- 3. associar utilizadores aos roles
grant role_aluno
to S1888,C1777,F1999;

select granted_role,grantee from dba_role_privs
where grantee in (select username from rep_f1.aluno);

--4. verificar privilégios e roles
SELECT role, privilege 
FROM role_sys_privs
WHERE upper(role) IN ('ROLE_ALUNO','CONNECT');

-- a role CONNECT já tem priv para criar sessao

--5. associar privilégios e roles aos roles
grant CONNECT to ROLE_ALUNO; -- associar role CONNECT a role_aluno
grant CREATE VIEW to ROLE_ALUNO; -- associar priv de criar vista

desc ROLE_ROLE_privs -- tabela para ver roles dados a outros roles

-- verificar se a role CONNECT foi dada a ROLE_ALUNO
SELECT role, granted_role FROM role_role_privs
WHERE role='ROLE_ALUNO';
-- ou WHERE role IN ('ROLE_ALUNO');

-- verificar se a role ROLE_ALUNO tem priv para criar vistas
DESC ROLE_SYS_PRIVS
SELECT ROLE,PRIVILEGE FROM ROLE_SYS_PRIVS
WHERE ROLE='ROLE_ALUNO'; -- consegue de facto criar vistas

-- EXERCICIO 6

conn / as sysdba

create user JALMEIDA identified by JALMEIDA;

--verificar se a role ROLE_FUNC já existe
select role from dba_roles
where upper(role)='ROLE_FUNC'; -- nao existe

-- logo devemos criar a role
create role ROLE_FUNC;
grant ROLE_FUNC to JALMEIDA;
GRANT CONNECT TO ROLE_FUNC;

desc dba_role_privs
select grantee, granted_role from dba_role_privs
where grantee='JALMEIDA'; -- JALMEIDA tem a ROLE_FUNC

desc role_role_privs
select role, granted_role from role_role_privs
where role='ROLE_FUNC'; -- A role ROLE_FUNC tem a role CONNECT associada

-- parte (*)
grant select, insert on rep_f1.aluno to role_func;
grant update(nome, morada) on rep_f1.aluno to role_func;



-- EXERCICIO 7
CONN / AS SYSDBA
GRANT CREATE VIEW TO REP_F1

CONN rep_f1/rep
CREATE OR REPLACE VIEW v_dados_exames
as SELECT local,data,categoria FROM EXAME
WHERE MONTHS_BETWEEN(SYSDATE,DATA)<1 AND MONTHS_BETWEEN(SYSDATE,DATA)>0;

GRANT SELECT ON v_dados_exames TO ROLE_ALUNO;

-- EXERCÍCIO 8
CONN rep_f1/rep

CREATE OR REPLACE VIEW V_DADOS_ALUNOS AS SELECT NOME,BI,MORADA,DATA_NASC
FROM ALUNO WHERE USERNAME=USER;
-- USERNAME é uma coluna da tabela ALUNO, USER é uma keyword que tem a string da conta 
-- que está a aceder à vista

GRANT SELECT ON V_DADOS_ALUNOS TO ROLE_ALUNO;

-- testar a vista num aluno da escola de condução
conn F1999/F1999
SELECT * FROM REP_F1.V_DADOS_ALUNOS;

-- EXERCICIO 9






































