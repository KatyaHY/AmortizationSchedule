--USE AmortizationScheduleDB
IF OBJECT_ID('TBL', 'U') IS NOT NULL DROP TABLE TBL


IF OBJECT_ID('Pmt', 'FN') IS NOT NULL DROP FUNCTION dbo.Pmt  
GO
CREATE FUNCTION dbo.Pmt (@r NUMERIC(18,4), @nper INT, @pv NUMERIC(18,4), @fv NUMERIC(18,4), @type INT)  
RETURNS NUMERIC(18,4)
AS  
BEGIN
    DECLARE @pmt NUMERIC(18,4)

    SET @pmt = @r / (Power(1.0 + @r, @nper) - 1.0) * -(@pv * Power(1.0 + @r, @nper) + @fv)

    if @type = 1  
 SET @pmt = @pmt / (1 + @r)
    RETURN @pmt
END  
GO


IF OBJECT_ID('Fv', 'FN') IS NOT NULL DROP FUNCTION dbo.Fv  
GO
CREATE FUNCTION dbo.Fv (@r NUMERIC(18,4), @nper INT, @c NUMERIC(18,4), @pv NUMERIC(18,4), @type INT)  
RETURNS NUMERIC(18,4)
AS  
BEGIN
    DECLARE @fv NUMERIC(18,4)

    IF @type = 1  
 SET @c = @c * (1 + @r);

    SET @fv = -(@c * (Power(1 + @r, @nper) - 1) / @r + @pv  
    * Power(1 + @r, @nper))

    RETURN @fv
END  
GO

IF OBJECT_ID('Ipmt', 'FN') IS NOT NULL DROP FUNCTION dbo.Ipmt  
GO
CREATE FUNCTION dbo.Ipmt (@r NUMERIC(18,4), @per INT, @nper INT, @pv NUMERIC(18,4), @fv NUMERIC(18,4), @type INT)  
RETURNS NUMERIC(18,4)   
AS  
BEGIN
    DECLARE @ipmt NUMERIC(18,4)
    SET @ipmt = dbo.Fv(@r, @per - 1, dbo.Pmt(@r, @nper, @pv, @fv, @type), @pv, @type) * @r

    if @type = 1  
 SET @ipmt = @ipmt / (1 + @r)
    RETURN @ipmt
END  
GO

IF OBJECT_ID('Ppmt', 'FN') IS NOT NULL DROP FUNCTION dbo.Ppmt  
GO
CREATE FUNCTION dbo.Ppmt (@r NUMERIC(18,4), @per INT, @nper INT, @pv NUMERIC(18,4), @fv NUMERIC(18,4), @type INT)  
RETURNS NUMERIC(18,4)   
AS  
BEGIN

    RETURN dbo.Pmt(@r, @nper, @pv, @fv, @type) - dbo.Ipmt(@r, @per, @nper, @pv, @fv, @type);

END  
GO

IF OBJECT_ID('nCalc', 'FN') IS NOT NULL DROP FUNCTION dbo.nCalc  
GO
CREATE FUNCTION dbo.nCalc(@num FLOAT, @dec INT)
RETURNS FLOAT
AS
BEGIN
SET @num = @num - @dec
RETURN @num
END
GO


DECLARE @PV as Float = -36000 --Loan Amount
,@FV as float = 0 --Value of the loan at termination
,@Term as float = 3 --The term of the loan in years
,@Pay_type as bit = 0 --Identifies the payment as due at the end (0) or the beginning (1) of the period
,@annual_rate as float = 0.0485 --The annual rate of interest
,@payment_frequency as float = 12 --The number of payments in a year
,@month as float --The term of the loan in months
,@rate as float
,@nper as float

Set @month = @payment_frequency * @Term +1
Set @rate = @annual_rate/@payment_frequency
Set @nper = @Term * @payment_frequency

;WITH
    Nbrs_3( n )
    AS
    (
                    SELECT 1
        UNION
            SELECT 0
    ),
    Nbrs_2( n )
    AS
    (
        SELECT 1
        FROM Nbrs_3 n1 CROSS JOIN Nbrs_3 n2
    ),
    Nbrs_1( n )
    AS
    (
        SELECT 1
        FROM Nbrs_2 n1 CROSS JOIN Nbrs_2 n2
    ),
    Nbrs_0( n )
    AS
    (
        SELECT 1
        FROM Nbrs_1 n1 CROSS JOIN Nbrs_1 n2
    ),
    Nbrs ( n )
    AS
    (
        SELECT 1
        FROM Nbrs_0 n1 CROSS JOIN Nbrs_0 n2
    )


SELECT * INTO TBL FROM (SELECT n as [Period]
, dbo.Fv(@rate,@nper-dbo.nCalc(@month,n),dbo.Pmt(@rate,@nper,@PV,@FV,@pay_type),@PV,@pay_type) as [Starting Balance]
, dbo.Pmt(@rate,@nper,@PV,@FV,@pay_type) as [Payment]
, dbo.Ipmt(@rate,dbo.nCalc(@month,n),@nper,@PV,@FV,@pay_type) as [Interest Payment]
, dbo.Ppmt(@rate,dbo.nCalc(@month,n),@nper,@PV,@FV,@pay_type) as [Principal Payment]
, dbo.Fv(@rate,@nper-(dbo.nCalc(@month,n)-1),dbo.Pmt(@rate,@nper,@PV,@FV,@pay_type),@PV,@pay_type) as [Ending Balance]
FROM ( SELECT ROW_NUMBER() OVER (ORDER BY n)
    FROM Nbrs ) D( n )
WHERE n <= @nper 
) as [fancy derived table]

SELECT * FROM TBL