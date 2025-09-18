using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace AdvancedExample
{
    public record Person(string Name, int Age);

    public interface IRepository<T> where T : class
    {
        Task<T?> GetByIdAsync(int id);
        Task<IEnumerable<T>> GetAllAsync();
    }

    public class PersonRepository : IRepository<Person>
    {
        private readonly List<Person> _people = new()
        {
            new("Alice", 30),
            new("Bob", 25),
            new("Charlie", 35)
        };

        public async Task<Person?> GetByIdAsync(int id)
        {
            await Task.Delay(10); // Simulate async work
            return _people.ElementAtOrDefault(id);
        }

        public async Task<IEnumerable<Person>> GetAllAsync()
        {
            await Task.Delay(10);
            return _people.Where(p => p.Age >= 18).ToList();
        }
    }

    public static class Program
    {
        public static async Task Main(string[] args)
        {
            var repository = new PersonRepository();
            var adults = await repository.GetAllAsync();

            foreach (var person in adults)
            {
                Console.WriteLine($"{person.Name} is {person.Age} years old");
            }
        }
    }
}