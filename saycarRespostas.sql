CREATE VIEW `saycarRespostas2` AS 
select `respostas`.`aluno` AS `aluno`,`questionarios`.`nome` AS `nome`,`questionarios`.`prefixo` AS `prefixo`,`respostas`.`entrada` AS `entrada`,`respostas`.`pergunta` AS `pergunta`,`respostas`.`ordem` AS `ordem`,`respostas`.`resposta` AS `resposta` from 
(`respostas` inner join `questionarios` on((`questionarios`.`id` = `respostas`.`questionario`))) order by `respostas`.`aluno`,`questionarios`.`nome`,`respostas`.`entrada`,`respostas`.`pergunta`;

CREATE VIEW `saycarRespostas6` AS
select * from respostas join sessoes on 
respostas.aluno = sessoes.aluno;

use saycar;

create view consultaQuestionarios as 
SELECT respostas.aluno, respostas.entrada, respostas.questionario, sessoes.data , questionarios.nome as nomeQuestionario , questionarios.prefixo, usuarios.usuario , usuarios.nome as nomeUsuario 
FROM respostas 
JOIN sessoes ON 
respostas.aluno = sessoes.aluno AND respostas.questionario = sessoes.questionario and respostas.entrada = sessoes.entrada
JOIN questionarios ON 
respostas.questionario = questionarios.id 
JOIN usuarios ON 
sessoes.usuario = usuarios.id
WHERE questionarios.id IN (1,12) AND sessoes.data LIKE '2018%'
group by respostas.aluno , respostas.entrada, respostas.questionario , sessoes.data, questionarios.nome, questionarios.prefixo, usuarios.usuario, usuarios.nome
ORDER BY respostas.aluno , respostas.entrada, respostas.questionario;


create view questionario as 
select * from respostas inner join questionarios on 
respostas.questionario = questionarios.id
order by respostas.aluno, respostas.questionario, respostas.pergunta, respostas.entrada;


create view consultasessoes as 
select sessoes.usuario as sessoesUsuario, usuarios.id as idUsuario , sessoes.aluno, sessoes.questionario, sessoes.entrada, sessoes.data , usuarios.usuario, usuarios.nome from sessoes inner join usuarios on 
sessoes.usuario = usuarios.id
order by sessoes.aluno, sessoes.questionario, sessoes.entrada;

create view consultaEntradas as 
select distinct questionario.aluno, questionario.nome, questionario.entrada as EntradaDoJeitoQueEstaNoBanco,
IF(questionario.entrada = 1 or questionario.entrada = 3 , "1",
	IF(questionario.entrada = 2 or questionario.entrada = 4,"2","Entrada Inválida")
) as EntradaDoJeitoQueEstaNoSistema
,consultasessoes.data, consultasessoes.usuario, consultasessoes.nome as nomeUsuario  from questionario inner join consultasessoes on 
questionario.aluno = consultasessoes.aluno and 
questionario.entrada = consultasessoes.entrada and 
questionario.questionario = consultasessoes.questionario
order by questionario.aluno, questionario.nome, EntradaDoJeitoQueEstaNoSistema;


create view consultaEntradas2 as 
select questionario.aluno, questionario.nome, questionario.questionario as idQuestionario, questionario.entrada, questionario.pergunta as idPergunta, questionario.ordem,
consultasessoes.data, consultasessoes.usuario, consultasessoes.nome as nomeUsuario  
from questionario inner join consultasessoes on 
questionario.aluno = consultasessoes.aluno and 
questionario.entrada = consultasessoes.entrada and 
questionario.questionario = consultasessoes.questionario
order by questionario.aluno, questionario.nome, questionario.entrada;


CREATE TEMPORARY TABLE dadosGerais (
numeroEntradas2017 varchar(100),
numeroSessoes2017 varchar(100),
numeroEntradas2018 varchar(100),
numeroSessoes2018 varchar(100),
numeroRespostas varchar(100),
numeroSessoes varchar(100)
)

select count(*) as numeroEntradas2017 from consultaEntradas2 where consultaEntradas2.data like "2017%";
select count(*) as numeroSessoes2017 from sessoes  where sessoes.data like "2017%";
select count(*) as numeroEntradas2018 from consultaEntradas2 where consultaEntradas2.data like "2018%";
select count(*) as numeroSessoes2018 from sessoes  where sessoes.data like "2018%";
select count(*) as numeroRespostas from respostas;
select count(*) as numeroSessoes from sessoes;
 

DELIMITER $$
CREATE PROCEDURE deletaDados2017 ()
BEGIN
declare aluno, nome, idQuestionario, entrada, idPergunta, ordem, data , usuario , nomeUsuario varchar(255);
declare finished int;
DECLARE entradas CURSOR FOR select * from consultaEntradas2;
DECLARE CONTINUE HANDLER FOR NOT FOUND SET finished = 1;

		OPEN entradas;
				get_linhasEntradas: LOOP
				   FETCH entradas INTO aluno, nome, idQuestionario, entrada, idPergunta, ordem, data , usuario , nomeUsuario;
				 
							 IF finished = 1 THEN 
							 LEAVE get_linhasEntradas;
							 END IF;
                             
                             if data like "2017%" then
                             
								 delete from respostas where 
								 respostas.aluno = aluno and 
								 respostas.entrada = entrada and 
								 respostas.questionario = idQuestionario and 
								 respostas.pergunta = idPergunta and 
								 respostas.ordem = ordem;
                                                                 
                                 delete from sessoes where
                                 sessoes.aluno = aluno and
                                 sessoes.entrada = entrada and 
                                 sessoes.questionario = questionario and 
                                 sessoes.data = data;
                                 
                                                        					 
                             end if;
				 END LOOP get_linhasEntradas;
		CLOSE entradas;
        
          select count(*) as numeroEntradas2018 from consultaEntradas2 where consultaEntradas2.data like "2018%";
		  select count(*) as numeroSessoes2018 from sessoes  where sessoes.data like "2018%";
   
END$$;
DELIMITER ;

CALL deletaDados2017();

SELECT COUNT( * ) 
FROM consultaEntradas2
WHERE consultaEntradas2.data LIKE  "2018%";



SET @listaEntradas = "";
CALL atualizaEntradas (@listaEntradas);
select @listaEntradas;



 SELECT listaEntradas 
        INTO OUTFILE 'C:/ProgramData/MySQL/MySQL Server 5.7/Uploads/entradas.csv' 
        FIELDS TERMINATED BY ';' 
        OPTIONALLY ENCLOSED BY '"' 
        LINES TERMINATED BY '\n';
        



SELECT @@GLOBAL.secure_file_priv;


SET CONCATENACAO=CONCAT(aluno,";",nome,";",entrada,";",data,";",usuario,";",nomeUsuario,"\n");
                     
                   SET listaEntradas = concat(listaEntradas,CONCATENACAO);
                   
                   SET CONCATENACAO = "";














