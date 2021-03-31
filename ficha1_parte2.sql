-- FICHA 1 - PARTE 2

-- funcões

CREATE OR REPLACE FUNCTION function_name(p_varname IN/OUT/IN OUT datatype, ...)
RETURN datatype AS
	-- SECÇÃO DECLARATIVA
BEGIN
 --CODE
 END function_name;
 /


-- EXERCICIO 1
--a)

-- função para verificar pw
CREATE OR REPLACE FUNCTION f_check_pw_alunos(p_username VARCHAR2, 
											 p_new_pw VARCHAR2, 
											 p_old_pw VARCHAR2)
RETURN BOOLEAN AS
BEGIN
	IF(LENGTH(p_new_pw)<6 OR UPPER(p_new_pw)=UPPER(p_old_pw) OR 
		LOWER(p_new_pw) IN ('password123','qwerty123') OR
		REGEXP_LIKE(p_new_pw,'[A-Z|a-z]') = FALSE
		OR REGEXP_LIKE(p_new_pw,'[0-9]') = FALSE) 
	THEN
		RETURN FALSE;
	ELSE
		RETURN TRUE;
	END IF;
END f_check_pw_alunos;
/

-- Na função verificamos se o tamanho da nova pw é inferior a 6, 
-- se a pw antiga e a pw nova são iguais independentemente se está em maiúsculas ou não,
-- se a nova pw é igual a 'password123','qwerty123' e ainda se a nova pw
-- é apenas composta por letras ou apenas por números. Se tal acontecer, a função irá
-- devolver FALSE caso a pw não respeite os requisitos. Senão, devolve true.

--testar função para verificar pw
SET SERVEROUTPUT ON
BEGIN
		IF f_check_pw_alunos('XPTO','password123','XXX') THEN
			DBMS_OUTPUT.PUT_LINE('bad password!');
		ELSE
			DBMS_OUTPUT.PUT_LINE('good password!');
		END IF;
END;
/

-- criar perfil
CREATE PROFILE perfil_aluno
LIMIT
		PASSWORD_VERIFY_FUNCTION f_check_pw_alunos;

-- associar perfil
ALTER USER S1888 PROFILE perfil_aluno;

-- perfis criados no mês atual(criados por nós)
SELECT username, profile FROM dba_users 
WHERE TO_CHAR(created,'MM.YYYY')=TO_CHAR(SYSDATE,'MM.YYYY');

-- testar perfil
conn S1888/S1888
ALTER USER S1888 IDENTIFIED BY nova_password;
-- ERROR -> deixamos de poder usar este comando se o perfil estiver associado
-- pois o perfil associado tem uma funcao como password_verify_function
-- e esta é igual a null no perfil DEFAULT
-- Para ver esta tabela dá jeito um 
SET LINESIZE 1000
SELECT RESOURCE_NAME, LIMIT, RESOURCE_TYPE
FROM dba_profiles WHERE profile='DEFAULT'
-- nesta tabela conseguimos verificar que a funcao password_verify_function é null
-- no perfil DEFAULT

conn C1777/C1777
ALTER USER S1888 IDENTIFIED BY nova_password;
-- já irá aceitar este comando pois a conta C1777 tem o perfil DEFAULT
-- que não tem a função associada, logo aceita qualquer password

conn S1888/S1888
ALTER USER S1888 IDENTIFIED BY nova_password REPLACE old_password;

-- verificar se o perfil_aluno tem a função associada
DESC dba_profiles
SET LINESIZE 1000
SELECT RESOURCE_NAME, LIMIT, RESOURCE_TYPE
FROM dba_profiles WHERE PROFILE='PERFIL_ALUNO';
-- A função f_check_pw_alunos aparece no campo de limit associada à password_verify_function

-- Associar todos os alunos
conn / as sysdba

-- ver todos os alunos para saber os nomes dos users para associar o perfil
desc DBA_ROLE_PRIVS
SELECT GRANTEE, GRANTED_ROLE FROM DBA_ROLE_PRIVS
WHERE UPPER(GRANTED_ROLE)='ROLE_ALUNO';

-- associar o perfil aos restantes
ALTER USER C1777 PROFILE perfil_aluno;
ALTER USER F1999 PROFILE perfil_aluno;

-- validação
DBA_PROFILES
DBA_USERS

-- testar para todos
conn C1777/C1777
ALTER USER C1777 IDENTIFIED BY nova_password REPLACE old_password;
conn F1999/F1999
ALTER USER F1999 IDENTIFIED BY nova_password REPLACE old_password;
-- d)
conn / as sysdba
ALTER PROFILE perfil_aluno
LIMIT
	FAILED_LOGIN_ATTEMPTS 3 --
	PASSWORD_LOCK_TIME 2/60/24 -- tempo de bloqueio após errar 3 vezes (representado em dias)
	PASSWORD_GRACE_TIME 5 -- notificação 5 dias que antecedem o limite de alteracao
	PASSWORD_LIFE_TIME 15 -- a pw expira a cada 15 dias
	PASSWORD_REUSE_TIME 30 -- reutilizar passe só após 30 dias
	PASSWORD_REUSE_MAX 2;
	-- FALTA BLOQUEAR A CONTA NAO SEJA USADA DURANTE 90 DIAS

-- validação
SELECT RESOURCE_NAME,LIMIT
FROM DBA_PROFILES WHERE LOWER(PROFILE)='perfil_aluno';

-- testar
-- f) Crie situações realistas que permitam testar todos os limites definidos.
conn C1777/123
conn C1777/432
conn C1777/778
-- A conta é bloqueada durante 2 minutos
-- Como é que testamos a notificação dos 5 dias antes do limite de alteração,
--  reutilização da pw ao fim de 30 dias, a pw expirar a cada 15 dias??

-- EXERCICIO 2
CONN / AS SYSDBA

CREATE PROFILE perfil_func
LIMIT
	SESSIONS_PER_USER 2
	CPU_PER_SESSION UNLIMITED
	CPU_PER_CALL 500
	CONNECT_TIME 2
	LOGICAL_READS_PER_CALL 10
	LOGICAL_READS_PER_SESSION 100;
	
-- CPU_PER_SESSION UNLIMITED, se omisso fica com o valor do perfil DEFAULT
-- SE O COMANDO TIVER MAIS DE 10 BLCOOS SIMPLESMENTE NAO VAMOS
-- CONSEGUIR REALIZAR ESSE COMANDO E APARECE UM ERRO

 show parameter DB_BLOCK_SIZE
-- na conta sys para ver o tamanho do bloco se for necessário

 show parameter RESOURCE_LIMIT
-- se tiver a false mesmo criando o perfil e associando ao utilizador, nunca serão aplicados
-- os limites

-- na versao 11g o valor por default é FALSE
-- na versão 19c o valor por default é TRUE	
 ALTER SYSTEM SET RESOURCE_LIMIT=TRUE SCOPE=BOTH
-- caso esteja a FALSE e queiramos colocar a TRUE
	
-- validar 
SELECT RESOURCE_NAME, LIMIT
FROM DBA_PROFILES WHERE LOWER(PROFILE)='perfil_func';

--associar perfil ao funcionário
CONN / AS SYSDBA
ALTER USER JALMEIDA PROFILE perfil_func;

--testar
-- LOGICAL_READS_PER_SESSION 100;
SELECT * FROM ALL_TABLES;
-- LOGICAL_READS_PER_CALL 10
SELECT
  2  RESOURCE_NAME
  3  ,LIMIT
  4  ,RESOURCE_TYPE
  5  FROM
  6  DBA_PROFILES
  7  WHERE
  8  LOWER(PROFILE)
  9  =
 10  'perfil_func';
 -- SESSIONS_PER_USER 2 
 -- Como assim? Como testo isto?
 -- CPU_PER_SESSION UNLIMITED
 -- Como testo isto?
 -- CPU_PER_CALL 500
  -- Como testo isto?
 -- CONNECT_TIME 2
  -- Como testo isto? Espero 2min enquanto estou logado?
  
 -- EXERCICIO 3
 
 -- permissoes de sys
  SELECT ROLE, PRIVILEGE
  FROM ROLE_SYS_PRIVS
  WHERE UPPER(ROLE) IN ('ROLE_ALUNO','ROLE_FUNC');
  -- ROLE_ALUNO - TEM PERMISSAO PARA CRIAR VISTAS
   
 -- permissoes de objeto

 SELECT DISTINCT ROLE, TABLE_NAME,PRIVILEGE
 FROM ROLE_TAB_PRIVS
 WHERE UPPER(ROLE) IN ('ROLE_ALUNO','ROLE_FUNC');
	-- ROLE_ALUNO - SELECT     V_DADOS_ALUNOS
	-- ROLE FUNC - UPDATE,INSERT,SELECT    ALUNO

-- revoke pela conta sys pq é um priv de sistema
conn / as sysdba
REVOKE CREATE VIEW FROM ROLE_ALUNO;
-- descobrir owners da vista e da tabela
CONN / AS SYSDBA
DESC DBA_TABLES
SELECT TABLE_NAME, OWNER
FROM DBA_TABLES WHERE UPPER(TABLE_NAME)='ALUNO';
-- OWNER DA TABELA ALUNO -> REP_F1
DESC DBA_VIEWS
SELECT VIEW_NAME,OWNER
FROM DBA_VIEWS WHERE UPPER(VIEW_NAME)='V_DADOS_ALUNOS';
-- OWNER DA VISTA V_DADOS_ALUNOS -> REP_F1

-- dar revoke pela conta owner da vista e da tabela
conn rep_f1/rep
REVOKE SELECT ON V_DADOS_ALUNOS FROM ROLE_ALUNO;
REVOKE UPDATE,INSERT,SELECT ON ALUNO FROM ROLE_FUNC;


















