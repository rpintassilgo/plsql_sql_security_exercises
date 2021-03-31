CREATE TABLE aluno (
  bi NUMBER (8),
  nome VARCHAR2(50) NOT NULL,
  morada VARCHAR2 (250) NOT NULL,
  data_nasc DATE,
  ult_categ_obtida CHAR(1),
  data_ult_categ_obtida DATE,
  total_reprovacoes NUMBER (2),
  username VARCHAR2(30) NOT NULL,
  CONSTRAINT pk_aluno_bi PRIMARY KEY (bi),
  CONSTRAINT uq_aluno_username UNIQUE (username),
  CONSTRAINT ck_Aluno_ultcategobt CHECK (ult_categ_obtida IN ('A','B', 'C', 'D', 'E')),
  CONSTRAINT ck_Aluno_totalreprovacoes CHECK (total_reprovacoes >= 0)
);
  
CREATE TABLE exame (
  id INTEGER,
  local VARCHAR2(100) NOT NULL,
  data DATE NOT NULL,
  categoria CHAR(1),
  CONSTRAINT pk_exame_inscricao PRIMARY KEY (id),
  CONSTRAINT ck_ExameCategoria CHECK (categoria IN ('A','B', 'C', 'D', 'E'))
);  

  
CREATE TABLE inscricao(
   id INTEGER,
   data_insc DATE NOT NULL,
   paga CHAR(1) NOT NULL,
   data_pagamento DATE,
   categoria  CHAR(1) NOT NULL,
   bi_aluno   NUMBER (8) NOT NULL,
   id_exame   INTEGER,
   resultado_exame VARCHAR2(20),
   CONSTRAINT pk_inscricao PRIMARY KEY(id),
   CONSTRAINT fk_inscricao_idExame FOREIGN KEY (id_exame) REFERENCES exame(id),
   CONSTRAINT fk_inscricao_biAluno FOREIGN KEY (bi_aluno) REFERENCES aluno(bi),
   CONSTRAINT uq_inscricao_biexame UNIQUE (bi_aluno, id_exame),
   CONSTRAINT ck_inscricao_id CHECK (id>0),
   CONSTRAINT ck_inscricao_paga CHECK (paga IN ('S','N')),
   CONSTRAINT ck_inscricao_resultado CHECK (resultado_exame IN ('A','R')),
   CONSTRAINT ck_inscricao_pagamento CHECK (data_insc<=data_pagamento),
   CONSTRAINT ck_inscricao_categoria CHECK (categoria IN ('A','B', 'C', 'D', 'E'))
);