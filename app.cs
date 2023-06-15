using System;
using System.Data.SqlClient;

namespace DotNetApp
{
    class Program
    {
        static void Main(string[] args)
        {
            string connectionString = "your_connection_string_here";

            using (SqlConnection connection = new SqlConnection(connectionString))
            {
                try
                {
                    connection.Open();
                    Console.WriteLine("Connected to the Azure SQL Database!");

                    // Perform database operations here

                    connection.Close();
                    Console.WriteLine("Disconnected from the Azure SQL Database!");
                }
                catch (Exception ex)
                {
                    Console.WriteLine($"Error: {ex.Message}");
                }
            }
        }
    }
}
