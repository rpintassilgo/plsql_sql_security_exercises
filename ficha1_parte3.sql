-- FICHA 1 - PARTE 3

-- CONFIGURAR AUDITORIA
DBA_PRIV_AUDIT_OPTS
DBA_OBJ_AUDIT_OPTS

-- ACEDER A AUDITORIA
DBA_AUDIT_TRAIL
DBA_AUDIT_OBJECT
DBA_AUDIT_SESSION

AUD$ -> GUARDADO AQUI
-- EXERCICIO 1
-- AS AUDITS SAO TODAS EXECUTADAS NO SYS
--a)
-- verificar se a AUDIT já existe
SELECT UPD FROM DBA_OBJ_AUDIT_OPTS WHERE UPPER(OWNER)='REP_F1';
-- Não existe AUDIT para update

-- criar a audit
AUDIT UPDATE ON REP_F1.ALUNO BY ACCESS;

SELECT UPD FROM DBA_OBJ_AUDIT_OPTS WHERE UPPER(OWNER)='REP_F1';
-- Como diz A/A, a AUDIT foi criada

--b)
desc dba_obj_audit_opts
SELECT OWNER, OBJECT_NAME, OBJECT_TYPE
FROM DBA_OBJ_AUDIT_OPTS WHERE UPPER(OWNER)='REP_F1';

-- c)
-- Realize atualizações bem-sucedidas, mas realizadas pelo utilizador dono do repositório
conn rep_f1/rep
update aluno
set nome='Teste2'
where bi=1777;
COMMIT;

conn / as sysdba
select username,extended_timestamp,action_name,returncode
from dba_audit_trail
where upper(obj_name)='ALUNO' AND upper(owner)='REP_F1';

-- Realize tentativas de atualização feitas por um user sem privilégios para tal
conn JALMEIDA/JALMEIDA
update rep_f1.aluno
set nome='Teste3'
where bi=1777;

conn / as sysdba
select username,extended_timestamp,action_name,returncode
from dba_audit_trail
where upper(obj_name)='ALUNO' AND upper(owner)='REP_F1';

-- EXERCICIO 2
-- a)
-- verificar se existe
DESC DBA_PRIV_AUDIT_OPTS
SELECT USER_NAME, PRIVILEGE, SUCCESS, FAILURE
FROM DBA_PRIV_AUDIT_OPTS
WHERE UPPER(USER_NAME)='REP_F1';
-- no rows selected, ou seja, nao existe AUDIT

-- AUDIT para sessão para pw errada
audit session by rep_f1 by access whenever not successful;
audit connect by rep_f1 by access whenever not successful;

-- verificar se foi criado
SELECT USER_NAME, PRIVILEGE, SUCCESS, FAILURE
FROM DBA_PRIV_AUDIT_OPTS
WHERE UPPER(USER_NAME)='REP_F1';

--b)
-- "situacao de ataque por password cracking"
conn rep_f1/qwertyu
-- (...)
desc dba_audit_trail
-- verificar o AUDIT
SELECT USERNAME, EXTENDED_TIMESTAMP, ACTION
FROM DBA_AUDIT_TRAIL
WHERE UPPER(USERNAME)='REP_F1';

-- c)
conn / as sysdba

-- criar perfil contra brute-force
CREATE PROFILE perfil_rep
LIMIT
	FAILED_LOGIN_ATTEMPTS 3
	PASSWORD_LOCK_TIME 15;
	
-- associar perfil
ALTER USER REP_F1 PROFILE perfil_rep;

DESC DBA_PROFILES
-- verificar se o perfil tem as restrições bem aplicacadas
SELECT RESOURCE_NAME, LIMIT, RESOURCE_TYPE
FROM DBA_PROFILES
WHERE UPPER(PROFILE)='PERFIL_REP' AND UPPER(RESOURCE_TYPE)='PASSWORD';

-- EXERCICIO 3

conn/ as sysdba
set markup csv ON
set termout OFF

-- começar a escrever
SPOOL E:\aulas\dump_audit_logon.csv REPLACE

SELECT username,extended_timestamp,action_name
from dba_audit_trail
where username='REP_F1' and action_name='LOGON'
order by timestamp DESC;

spool off;
-- parar de escrever

-- apagar entradas no sistema de auditoria
delete from aud$
where userid='REP_F1' and action# IN 
(SELECT ACTION from audit_actions where name in('LOGON'));

-- tabela audit_actions mostra o codigo da ação correspondente ao nome da ação
-- EXEMPLO: 100 -> LOGON

-- EXERCÍCIO 4
-- Ative, verifique e teste a auditoria da base de dados nas situações em que no repositório de dados
-- sejam criadas novas tabelas.

-- Fazer amanha

-- EXERCICIO 5
-- Desligue os níveis de auditoria que definiu nas alíneas anteriores para evitar sobrecarga desnecessária
-- do tablespace onde são armazenados os registos de auditoria.


	
	
	













