conn / as sysdba
GRANT EXECUTE ON dbms_crypto TO rep_f1;

conn rep_f1/rep

CREATE OR REPLACE FUNCTION f_cifrar(p_string_to_encrypt IN VARCHAR2) RETURN RAW AS
   ----------Restrições -----------------------------------
   -- A chave tem de ter 32 bytes
   -- DBMS_CRYPTO: https://docs.oracle.com/en/database/oracle/oracle-database/19/arpls/DBMS_CRYPTO.html#GUID-4B200807-A740-4A2E-8828-AC0CFF6127D5

   -- gurada a cifragem realizada
   encrypted_raw RAW (2000);
   encryption_type PLS_INTEGER:=DBMS_CRYPTO.ENCRYPT_AES256+DBMS_CRYPTO.CHAIN_CBC+DBMS_CRYPTO.PAD_PKCS5;

BEGIN
   encrypted_raw:=DBMS_CRYPTO.ENCRYPT
                  (src => UTL_I18N.STRING_TO_RAW (p_string_to_encrypt,  'AL32UTF8'),
                   typ => encryption_type,
                   key => UTL_RAW.CAST_TO_RAW('12345678901234567890123456789012'));

  RETURN encrypted_raw;
EXCEPTION
   WHEN dbms_crypto.KeyNull THEN
      RAISE_APPLICATION_ERROR(-20001,'Erro na cifragem: a chave é obrigatória.');
   WHEN dbms_crypto.KeyBadSize THEN
      RAISE_APPLICATION_ERROR(-20001,'Erro na cifragem: o tamanho da chave deve ser 32 bytes.');
   WHEN OTHERS THEN
      RAISE_APPLICATION_ERROR(-20001,'Erro na cifragem: contacte o administrador.');
END;
/

CREATE OR REPLACE FUNCTION f_decifrar(p_encrypted_raw IN RAW) RETURN VARCHAR2 AS
   -- guarda a decifragem realizada
   decrypted_raw RAW (2000); 
   ----------Restrições -----------------------------------
   -- A chave tem de ter 32 bytes
   -- DBMS_CRYPTO: https://docs.oracle.com/en/database/oracle/oracle-database/19/arpls/DBMS_CRYPTO.html#GUID-4B200807-A740-4A2E-8828-AC0CFF6127D5

   -- total encryption type
   encryption_type PLS_INTEGER:=DBMS_CRYPTO.ENCRYPT_AES256+DBMS_CRYPTO.CHAIN_CBC+DBMS_CRYPTO.PAD_PKCS5;
BEGIN
    decrypted_raw := DBMS_CRYPTO.DECRYPT
      (  src => p_encrypted_raw,
         typ => encryption_type,
         key => UTL_RAW.CAST_TO_RAW('12345678901234567890123456789012')
      );
    RETURN UTL_I18N.RAW_TO_CHAR (decrypted_raw, 'AL32UTF8');
  EXCEPTION
   WHEN dbms_crypto.KeyNull THEN
      RAISE_APPLICATION_ERROR(-20001,'Erro na cifragem: a chave é obrigatória.');
   WHEN dbms_crypto.KeyBadSize THEN
      RAISE_APPLICATION_ERROR(-20001,'Erro na cifragem: o tamanho da chave deve ser 32 bytes.');
   WHEN OTHERS THEN
      RAISE_APPLICATION_ERROR(-20001,'Erro na cifragem: contacte o administrador.');
END;
/