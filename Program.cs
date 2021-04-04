using Microsoft.SqlServer.Management.Common;
using Microsoft.VisualBasic;
using System;
using System.Collections.Generic;
using System.Data;
using Microsoft.Data.SqlClient;
using System.IO;
using System.Linq;
using Server = Microsoft.SqlServer.Management.Smo.Server;


namespace AmortizationSchedule
{

    class Program
    {
        static void Main(string[] args)
        {
            string connString = @"Data Source=DESKTOP-G9K9R68" + ";Initial Catalog=AmortizationScheduleDB" + ";Integrated Security=True";

            SqlConnection connection = new SqlConnection(connString);
            int paymentCnt = 12;
            double pv;
            int fv = 0;
            int term = 4;
            DueDate pay_type = 0;
            double annual_rate = 0.061;
            int payment_frequency = 12;
            double rate = annual_rate / payment_frequency;
            int nper = term * payment_frequency;

            double startingBalance;
            double payment;
            double interestPayment;
            double principalPayment;
            double endingBalance;

            DataTable table = new DataTable("amortization_schedule");

            connection.Open();
            string script = File.ReadAllText(@"C:\Users\katya\source\repos\AmortizationSchedule\SQLQuery.sql");

            Server server = new Server(new ServerConnection(connection));
            server.ConnectionContext.ExecuteNonQuery(script);
            SqlCommand cmd = new SqlCommand("select * from TBL",connection);
            cmd.Connection = connection;
            SqlDataAdapter dap = new SqlDataAdapter(cmd);
            dap.Fill(table);
            connection.Close();

            Console.WriteLine("Amortization Schedule of a loan of 36000 NIS, interest 3.25% + prime 1.6% for 36 monthly payments:\n");
            Console.WriteLine("          {0}          {1}         {2}     {3}    {4}", "Starting balance", "Payment", "Interest payment", "Principal payment", "Ending balance");

            for (int i = 0; i < paymentCnt; i++)
            {

                    for (int j = 0; j < table.Columns.Count; j++)
                    {

                    Console.Write("{0}            ", table.Rows[i][j]);

                    }
                Console.Write("\n");
 
            }

            pv = Convert.ToDouble(table.Rows[11][1].ToString());

            Console.WriteLine("\n\nA loan recycle after 12th payment with with a fixed interest of 4.5% for an additional 48 payments:\n");
            Console.WriteLine("          {0}          {1}         {2}     {3}    {4}", "Starting balance", "Payment", "Interest payment", "Principal payment", "Ending balance");
            //Console.WriteLine("{0,20} {1,20} {2,20} {3,20} {4,20}", "Starting balance", "Payment", "Interest payment", "Principal payment", "Ending balance");

            for (int j = nper, i=1; j >= 1; j--,i++)
            {

                payment=-(Financial.Pmt(rate, nper, pv, fv, pay_type));
                startingBalance=-(Financial.FV(rate, nper - j, Financial.Pmt(rate, nper, pv, fv, pay_type), pv, pay_type));
                interestPayment=-(Financial.IPmt(rate, j, nper, pv, fv, pay_type));
                principalPayment = -(Financial.PPmt(rate, j, nper, pv, fv, pay_type));
                endingBalance =-(Financial.FV(rate, nper-(j-1), Financial.Pmt(rate, nper, pv, fv, pay_type), pv, pay_type));

                Console.WriteLine("{0}            {1:0.0000}            {2:0.0000}            {3:0.0000}            {4:0.0000}            {5:0.0000}", i, startingBalance, payment, interestPayment, principalPayment, endingBalance);

            }
        }
    }
}
