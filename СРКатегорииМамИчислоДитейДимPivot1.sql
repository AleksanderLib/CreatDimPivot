use monitoringdeath

declare @nk nvarchar(4000) = '', 
        @nk1 nvarchar(4000)= '',
        @nk2 nvarchar (4000)= '',
        @date1 date = '19-09-2020',
        @s nvarchar(10) 

SELECT @nk = @nk + '[' + convert(varchar(3),[NumberKidFromMother])+']'+', ',@nk1 = @nk1 + '['+ convert(varchar(3),[NumberKidFromMother])+'] as ''k'+convert(varchar(3),[NumberKidFromMother])+''',',
@nk2=@nk2 + '['+ convert(varchar(3),[NumberKidFromMother])+']'+'+' 
FROM [MonitoringDeath].[dbo].[tbl_SvidetelstvoBirth]
where  datepart(year,[DateIssueSv])=datepart(year,@date1)
group by NumberKidFromMother
order by [NumberKidFromMother]
 
Set @nk = left (@nk,len(@nk)-1)
Set @nk1= left (@nk1,len(@nk1)-1)
set @nk2 =left (@nk2,len(@nk2)-1)
Set @s = left(@date1,4);


declare @Query nvarchar(4000) = N'

with table_CTE(NKids,Category)
as
(
select 
       [NumberKidFromMother],
       
case 
when ym <25 then  ''до 25 лет'' 
when ym>=25 and ym<=29 then  ''от 25 до 29''
when ym>=30 and ym<=34 then  ''от 30 до 34''
when ym>=35 and ym<=39 then  ''от 35 до 39''
else ''40 и старше''
end as category

  from (
select 
	(SELECT years FROM [dbo].[CalcAge] ([BirthDayMother],[BirthDayKid])) ym,
	(SELECT years FROM [dbo].[CalcAge] ([BirthDayKid],'''+convert(nvarchar(10),@date1)+''')) yk,
	(SELECT months FROM [dbo].[CalcAge] ([BirthDayKid],'''+convert(nvarchar(10),@date1)+''')) mk,

	 [NumberKidFromMother]
from tbl_BirthKid bk
join tbl_SvidetelstvoBirth svb on bk.id_BirthKid= svb.id_BirthKid
Where [BirthDayKid] not like ''%X%'' and BirthDayKid like ''%'+@s+'''
)tmp 
where yk=0 and mk<datepart(month,'''+convert(nvarchar(10),@date1)+''')
)
select [Category],'+@nk2+'as Sum,'+@nk1+' from table_CTE
pivot (count([NKids]) for [NKids] in ('+@nk+'))
as pvt'

exec sp_executesql @Query




