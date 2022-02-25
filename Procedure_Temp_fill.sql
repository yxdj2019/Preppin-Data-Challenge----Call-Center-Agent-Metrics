-- stored procedure
delimiter $$
Create procedure Temp_fill ()
begin
	declare i int default 1;
	While i<136 do
		insert into temp(AgentID) values (i);
		set i=i+1;
	End while;
end $$

delimiter ;
