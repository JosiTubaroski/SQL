

ALTER function [dbo].[fncDia_Util_Anterior]( @dt_dia smalldatetime, @dias_uteis int )
returns smalldatetime
as
begin
declare @contador int
set @contador = 1

--set @dt_dia = dateadd(day, -1, @dt_dia)

    while (@contador <= @dias_uteis)
    begin
 
        if exists (select top 1 cd_feriado from dbo.tgr_feriados with (nolock) 
                   where dt_feriado = dateadd(day, -1, @dt_dia)) 
                   or (datepart(weekday, dateadd(day, -1, @dt_dia)) in (7, 1)) 
        begin
           set @dt_dia = dateadd(day, -1, @dt_dia)
            
            set @contador = @contador - 1 
            
        end    
        else
        begin
        
            set @dt_dia = dateadd(day, -1, @dt_dia) 
        end
        
        set @contador = @contador + 1 
    end
 
    return @dt_dia
 
end
