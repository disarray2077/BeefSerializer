# BeefSerializer

BeefSerializer is a BeefLang library designed for fast binary serialization, fast means **no runtime reflection**, all serialization methods are generated in compile-time.

## Quick Start

```bf
using System;
using System.Collections;
using BeefSerializer;

namespace BeefSerializerSample
{
	class Program
	{
		[AutoGenSerializable]
		public class Game
		{
			public String Title ~ delete _;
			public uint64 Id;
			public bool Active;
			public List<Player> Players = new .() ~ DeleteContainerAndItems!(_);
		}
		
		[AutoGenSerializable]
		public class Player
		{
			public String Name ~ delete _;
			public int32 Level;
		}

		public static void Main()
		{
			BasicBuffer buff = scope .();
			Serializer ser = scope .(buff);

			Game game = scope .()
			{
				Title = new .("Flappy Beef"),
				Id = 1
			};

			Player player = new .()
			{
				Name = new .("disarray"),
				Level = 2077
			};
			game.Players.Add(player);

			// Serializes 'game' as bytes to the end of the buffer.
			ser.Put(game);
			game = null;

			String quotedStr = String.Quote((.)buff.Ptr, buff.Length, .. scope .());
			Console.WriteLine(quotedStr); // "\0\v\0\0\0Flappy Beef\x01\0\0\0\0\0\0\0\0\0\x01\0\0\0\0\b\0\0\0disarray\x1D\b\0\0"

			// Deserializes 'game' from the same buffer. A new "game" instance will be allocated in the heap!
			ser.Get(ref game);
			defer delete game;

			Console.WriteLine(game.Players[0].Name); // "disarray"
		}
	}
}
```