DECLARE @Counter INT = 1;

WHILE @Counter <=3 

BEGIN
	 SELECT @Counter AS CurrentValue 
	 SET @Counter = @Counter +1
END