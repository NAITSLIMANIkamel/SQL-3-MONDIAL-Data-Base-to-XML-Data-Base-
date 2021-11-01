-- CREATION DE TYPES ET TABLES

-- MONTAGNES 
drop type T_Montagne force;
/
create or replace  type T_Montagne as object (
   NAME         VARCHAR2(35 Byte),
   MOUNTAINS    VARCHAR2(35 Byte),
   HEIGHT       NUMBER,
   TYPE         VARCHAR2(10 Byte),
   CODEPAYS         VARCHAR2(4),
   -- COORDINATES  GEOCOORD,
   member function toXML return XMLType
)
/

create or replace type body T_Montagne as
 member function toXML return XMLType is
   output XMLType;
   begin
      output := XMLType.createxml('<montagne/>');
      output := XMLType.appendchildxml(output,'montagne', XMLType('<nom>'||name||'</nom>'));
      return output;
   end;
end;
/

drop table LesMontagnes;

create table LesMontagnes of T_Montagne;


-- PAYS
drop table LesPays;

create or replace  type T_Pays as object (
   NAME        VARCHAR2(35 Byte),
   CODE        VARCHAR2(4 Byte),
   CAPITAL     VARCHAR2(35 Byte),
   PROVINCE    VARCHAR2(35 Byte),
   AREA        NUMBER,
   POPULATION  NUMBER,
   member function toXML return XMLType
)
/
create or replace type T_ensMontagne as table of T_Montagne;
/
create or replace type body T_Pays as
   member function toXML return XMLType is
   output XMLType;
   -- V_montagnes T_ensXML;
   tmpMontagne T_ensMontagne;
   begin
      output := XMLType.createxml('<pays/>');
      output := XMLType.appendchildxml(output,'pays', XMLType('<nom>'||name||'</nom>'));
      output := XMLType.appendchildxml(output,'pays', XMLType('<code>'||code||'</code>'));
      select value(m) bulk collect into tmpMontagne
      from LesMontagnes m
      where code = m.codepays ;  
      for indx IN 1..tmpMontagne.COUNT
      loop
         output := XMLType.appendchildxml(output,'pays', tmpMontagne(indx).toXML());   
      end loop;
      return output;
   end;
end;
/

drop table LesPays;
/
create table LesPays of T_Pays;
/

-- INSERTIONS

insert into LesPays
  select T_Pays(c.name, c.code, c.capital, 
         c.province, c.area, c.population) 
         from COUNTRY c;
         


insert into LesMontagnes
  select T_Montagne(m.name, m.mountains, m.height, 
         m.type, g.country) 
         from MOUNTAIN m, GEO_MOUNTAIN g
         where g.MOUNTAIN=m.NAME;


       
-- affichage du r�sultat
-- @WbOptimizeRowHeight lines=100
select p.toXML().getClobVal() 
from LesPays p;


-- exporter le r�sultat dans un fichier 
WbExport -type=text
         -file='pays.xml'
         -createDir=true
         -encoding=ISO-8859-1
         -header=false
         -delimiter=','
         -decimal=','
         -dateFormat='yyyy-MM-dd'
/
select p.toXML().getClobVal() 
from LesPays p;


-- exporter le r�sultat dans un fichier 
WbExport -type=text
         -file='montagnes.xml'
         -createDir=true
         -encoding=ISO-8859-1
         -header=false
         -delimiter=','
         -decimal=','
         -dateFormat='yyyy-MM-dd'
/
select m.toXML().getClobVal() 
from LesMontagnes m;



