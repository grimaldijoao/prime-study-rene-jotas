using System;
using System.IO;
using System.Net.Http;
using System.Threading.Tasks;

namespace PrimeFileHandler
{
    public class Julia
    {
        HttpClient client = new HttpClient();

        private async Task<HttpResponseMessage> RequestExpression(string expression, bool cache = false)
        {
            var expr = Uri.EscapeDataString(expression);
            var url = $"http://127.0.0.1:8000/?expr={expr}&cache={cache.ToString().ToLower()}";

            var response = await client.GetAsync(url, HttpCompletionOption.ResponseHeadersRead);

            return response;
        }

        public async Task<HttpResponseMessage> GetMersenneResponse (string p)
        {
            return await RequestExpression($"2^BigInt({p})-1", true);
        }

        public async Task<string> test(string p)
        {
            var response = await RequestExpression($"getPrimePosition({p})");
            using (var stream = await response.Content.ReadAsStreamAsync())
            {
                return new StreamReader(stream).ReadToEnd();
            }
        }

        public async Task<int> GetPrimeCol(string p)
        {
            var response = await RequestExpression($"getPrimePosition({p})[1]");
            using (var stream = await response.Content.ReadAsStreamAsync())
            {
                return int.Parse(new StreamReader(stream).ReadToEnd());
            }
        }

        public async Task<int> GetPrimeLine(string p)
        {
            var response = await RequestExpression($"getPrimePosition({p})[1]");
            using (var stream = await response.Content.ReadAsStreamAsync())
            {
                return int.Parse(new StreamReader(stream).ReadToEnd());
            }
        }

        //Get a col 7 line from a line of any other col (ie: 2^(number from col 5)-1 results in which line of col 7?)
        //yes they always exist in col 7...
        public async Task<string> GetPossibleMersenneLine(string i, string p = "5")
        {
            var response = await RequestExpression($"getPossibleMersenneLine(big({i}), big({p}))");
            using (var stream = await response.Content.ReadAsStreamAsync())
            {
                return new StreamReader(stream).ReadToEnd();
            }
        }

        public async Task<string> GetPossibleMersennePFromLine(string line)
        {
            var response = await RequestExpression($"getPossiblePrimeAsMersenneP(big({line}))");
            using (var stream = await response.Content.ReadAsStreamAsync())
            {
                return new StreamReader(stream).ReadToEnd();
            }
        }

        public async Task<string> IsMersenneCandidate(string col, string line)
        {
            var response = await RequestExpression($"is_mersenne_candidate(big({col}), big({line}))");
            using (var stream = await response.Content.ReadAsStreamAsync())
            {
                return new StreamReader(stream).ReadToEnd();
            }
        }
    }
}
