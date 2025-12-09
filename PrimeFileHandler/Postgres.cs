using Npgsql;

namespace PrimeFileHandler
{
    public class Postgres
    {
        private string connString;
        public Postgres(string connString)
        {
            this.connString = connString;
        }

        private NpgsqlConnection Connection;
        private NpgsqlTransaction Transaction;
        private NpgsqlCommand Command;

        private NpgsqlConnection Connect()
        {
            if (Connection == null)
            {
                Connection = new NpgsqlConnection(connString);
                Connection.Open();
            }

            return Connection;
        }

        private NpgsqlTransaction BeginTransaction()
        {
            if (Transaction == null)
            {
                Connect();
                Transaction = Connection.BeginTransaction();
            }

            return Transaction;
        }

        private NpgsqlCommand GetCommand()
        {
            if (Command == null)
            {
                Command = new NpgsqlCommand();
            }

            return Command;
        }

        public void CommitTransactions()
        {
            Transaction.Commit();
            Connection.Close();
            Command.Dispose();
            Command = null;

            Transaction.Dispose();
            Transaction = null;

            Connection.Dispose();
            Connection = null;
        }

        public void SavePrimeMetadata(long p, int col, int p_col, int starts, int ends)
        {
            var command = GetCommand();

            command.Connection = Connect();
            command.Transaction = BeginTransaction();
            command.CommandText = "INSERT INTO prime_metadata (starts, ends, p, col, p_col) VALUES (@val1, @val2, @val3, @val4, @val5)";

            command.Parameters.Clear();
            command.Parameters.AddWithValue("val1", starts);
            command.Parameters.AddWithValue("val2", ends);
            command.Parameters.AddWithValue("val3", p);
            command.Parameters.AddWithValue("val4", col);
            command.Parameters.AddWithValue("val5", p_col);

            command.ExecuteNonQuery();

        }
    }
}
