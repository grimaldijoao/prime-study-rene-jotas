using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.IO;
using System.Linq;
using System.Net.Http;
using System.Threading.Tasks;

namespace PrimeFileHandler
{
    internal class Program
    {
        static int first = -1;
        static int last = -1;
        static Julia julia = new Julia();

        static string connString = "Host=185.139.1.29;Username=postgres;Password=15711Primos;Database=postgres";

        static async Task Main(string[] args)
        {
            Console.WriteLine(await julia.test("191147927718986609689229466631454649812986246276667354864188503638807260703436799058776201365135161278134258296128109200046702912984568752800330221777752773957404540495707851421041"));
            return;
            var postgres = new Postgres(connString);
            //for (int i = 1000; i < 2000; i++)
            //{
            //    var mersenneLine = await julia.GetPossibleMersenneLine(i.ToString());
            //    var mersenneP = await julia.GetPossibleMersennePFromLine(mersenneLine);
            //    var isPrime = await julia.IsMersenneCandidate(5.ToString(), i.ToString()) == "true";
            //    if(isPrime)
            //    {
            //        Console.WriteLine($"2^{mersenneP} - 1");
            //        postgres.SavePrimeMetadata(long.Parse(mersenneP), 7, 5, -1, -1);
            //        postgres.CommitTransactions();
            //    }
            //}
            //return;

            //TODO pegar lista de M que é da coluna 5
            var greenIndices = new HashSet<int>
            {
                1, 2, 3, 4, 5, 6, 8, 44, 355, 808, 829, 935, 1662, 1809, 71620
            };

            var yellowIndices = new HashSet<int>(greenIndices.Select(i => i - 1));

            var allIndices = greenIndices
                .Concat(yellowIndices)
                .Distinct()
                .OrderBy(i => i);

            string previous = "";
            int failed = 0;
            int success = 0;
            foreach (var i in allIndices)
            {
                var mersenneLine = await julia.GetPossibleMersenneLine(i.ToString());
                var mersenneP = await julia.GetPossibleMersennePFromLine($"getPossibleMersenneLine(big({i}), big(5))");
                var lastTwoChars = mersenneLine.Substring(Math.Max(0, mersenneLine.Length - 2));


                if (greenIndices.Contains(i))
                {
                    Console.ForegroundColor = ConsoleColor.Green;
                    Console.WriteLine($"{i}. {mersenneLine} (2^{mersenneP}-1)");
                    Console.ResetColor();
                    Console.WriteLine();
                    previous = lastTwoChars;
                }

                if (yellowIndices.Contains(i))
                {
                    Console.ForegroundColor = ConsoleColor.Yellow;
                    Console.WriteLine($"{i}. {mersenneLine} ({previous})");
                    Console.ResetColor();

                    if(lastTwoChars == previous)
                    {
                        success++;
                    }
                    else
                    {
                        failed++;
                    }
                }

            }

            Console.WriteLine($"Failed: {failed} - Success: {success}");


            return;


            var files = Directory.GetFiles(Environment.CurrentDirectory + "/Primes")
                .Where((name) => name.EndsWith(".txt"))
                .Select((x) => int.Parse(Path.GetFileName(x).Replace("M", "").Replace(".txt", "")));

            Stopwatch sw = new Stopwatch();
            sw.Start();

            var orderedArray = files.OrderBy((name) => name);

            foreach (int p in orderedArray)
            {
                Console.WriteLine($"Calculating M{p}...");
                Console.WriteLine();
                Dictionary<char, int> numberOccurrences = new Dictionary<char, int>();
                first = -1;

                using (var response = await julia.GetMersenneResponse(p.ToString()))
                using (var stream = await response.Content.ReadAsStreamAsync())
                using (var bs = new BufferedStream(stream, 65536))
                using (var sr = new StreamReader(bs))
                {
                    char[] buffer = new char[4096];
                    int charsRead;
                    while ((charsRead = sr.Read(buffer, 0, buffer.Length)) > 0)
                    {
                        for (int i = 0; i < charsRead; i++)
                        {
                            char number = buffer[i];
                            if (number == '\r' || number == '\n') continue;
                            if(first == -1)
                            {
                                first = number - 48;
                            }

                            // Process character
                            if (numberOccurrences.ContainsKey(number))
                            {
                                numberOccurrences[number]++;
                            }
                            else
                            {
                                numberOccurrences.Add(number, 1);
                            }

                            last = number - 48;
                        }
                    }
                }

                foreach (char number in numberOccurrences.Keys.OrderBy(c => numberOccurrences[c]).Reverse())
                {
                    Console.WriteLine($"{number} occurred {numberOccurrences[number]} times");
                }

                Console.WriteLine();

                Console.Write($"Total: {numberOccurrences.Sum((occurrence) => occurrence.Value)}");

                Console.Write($" / Starts with {first}");
                if (last != -1)
                {
                    Console.Write($" ends with {last}");  //TODO order by frequency
                                                          //TODO check binary relations of numbers that end with the same (like not only col 5 but col 13 also always ends with 1)
                                                          //TODO maybe its a sequence between two cols?
                }

                // Average, differences, and stability
                var counts = numberOccurrences.Values.ToList();
                double average = counts.Average();
                double avgDiff = counts.Select(c => Math.Abs(c - average)).Average();
                double maxDiff = counts.Max() - counts.Min();

                // Stability is 100% when all counts are the same
                double stability = maxDiff == 0 ? 100.0 : 100.0 - (avgDiff / average * 100.0);

                Console.WriteLine($"\nAverage Count: {average:F2}");
                Console.WriteLine($"Average Difference from Mean: {avgDiff:F2}");
                Console.WriteLine($"Stability: {stability:F2}%");

                Console.WriteLine();
                Console.WriteLine();
                Console.WriteLine();
                Console.WriteLine();

                if(p > 3)
                {
                    //postgres.SavePrimeMetadata(p, julia.GetPrimeCol($"(2^BigInt({p}))-1").GetAwaiter().GetResult(), julia.GetPrimeCol($"BigInt({p.ToString()})").GetAwaiter().GetResult(), first, last);
                }
            }

            //postgres.CommitTransactions();
            Console.WriteLine($"Finished in {sw.Elapsed}");
            
            Console.ReadLine();
        }
    }
}
