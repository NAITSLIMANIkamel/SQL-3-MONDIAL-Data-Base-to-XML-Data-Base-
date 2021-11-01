create or replace type T_encompasse as object(
     continent varchar2(50),
     percent number,
     country varchar(4)
);
/

create table encompasse of T_encompasse(continent not Null,country not null,percent not NULL);
create or replace type T_EnsEncompasse as table of T_encompasse  ;
------------------------------------------------------------------------------------------------------------------------------------
create or replace type T_borders as object(
     country1 varchar2(4),
     country2 varchar2(4),
     length number
);
/

create table border of T_borders(country1 not Null,country2 not null);
------------------------------------------------------------------------------------------------------------------------------------

create or replace type T_Border as object(
    countryCode varchar2(4),
    blength number
);
/


create type T_EnsBorder as table of T_Border;

create type contCountries as object (
    frontiere T_EnsBorder
);
/

create or replace TYPE T_Country as OBJECT(
    code varchar2(5),
    name VARCHAR2(60),
    member function continentPrincipale return varchar2,
    member function BorderPays return contCountries,
    member function blength return number 
    
);
/
create or replace type EnsCountry as table of T_Country;


create or replace type body T_Country as
   member function continentPrincipale return varchar2 is
   continent varchar2(50);
   begin
      select e1.continent into continent from encompasse e1  
      where e1.country= self.code and e1.percent= (select max(e2.percent) from encompasse e2 where e2.country=self.code) ;  
      return continent;
   end;
   
   member function BorderPays return contCountries is
   bCountry T_EnsBorder ;
   pays EnsCountry;
   begin
        select value(c) bulk collect into pays from countries c ,encompasse e where self.continentPrincipale()=e.continent and self.code <>e.country and c.code=e.country;--tout les pays du continent--
        
        select  cast(collect(T_Border(value(p).code,b.length)) as T_EnsBorder) into bCountry
        from table(pays) p ,border b 
         where (b.country1=self.code and b.country2=value(p).code and value(p).code=b.country2 ) 
                                                   or 
               (b.country2=self.code and b.country1=value(p).code and value(p).code=b.country1);
         return contCountries(bCountry); 
   end;
   
   member function blength return number is
      result number ;
      border T_EnsBorder;
      begin
      border := self.BorderPays().frontiere ;
      select sum(value(b).blength) into result from table(border)b ;
      return result;
      end;
end;
/




create table countries of T_Country;

insert into encompasse (select T_encompasse(e.continent,e.percentage,e.country) from encompasses e);
insert into border (select T_borders(b.country1,b.country2,b.length) from borders b);
insert into countries (select T_Country(c.code,c.name) from country c);

select c2.name from countries c,countries c2 ,table( c.BorderPays().frontiere) b where c.code='DZ' and b.countrycode=c2.code ;

select sum(value(b).blength) from countries c,table( c.BorderPays().frontiere) b where c.code='DZ';
select c.blength() from countries c where c.code='DZ';



select * from countries;
