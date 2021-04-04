# AmortizationSchedule
1.Calculates an amortization scheduleof a loan of 36000 NIS, and the interest is 3.25% + prime 
(the interest following the bank of Israel rate) for 36 monthly payments by calling a stored 
procedure in MSSQL that is written in T-SQL language.
2.Calculates loan recycling after the 12th payment on the remaining amount  with a fixed interest 
of 4.5% for an additional 48 payments.

1. Run "SQLQuery.sql" file in MSSQL.
2. Open AmortizationSchedule in VisualStudio.
3. Change: connString = @"Data Source=YOUR_DATA_SOURCE_HERE" + ";Initial Catalog=AmortizationScheduleDB" + ";Integrated Security=True"
4. Run
