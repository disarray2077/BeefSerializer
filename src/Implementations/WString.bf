using System;
using System.Diagnostics;
using BeefSerializer;

namespace BeefSerializer
{
	// String class that gets serialized as a WideString.
	class WString : String, ISerializable
	{
		[AllowAppend]
		public this() : base()
		{
		}
	
		[AllowAppend]
		public this(String str) : base(str)
		{
		}
	
		[AllowAppend]
		public this(char8* char8Ptr) : base(char8Ptr)
		{
		}
	
		public void Serialize(Serializer ser)
		{
			Debug.Assert(Length >= 0 && Length <= 0xffff);
	
			uint32 size = (.)Length * 2;
			ser.Put(size);
	
			if (size == 0)
				return;
	
			for (let char in DecodedChars)
				ser.PutMemory((char16)char);
		}
	
		public SerializerResult Deserialize(Serializer ser)
		{
			uint32 size = ?;
			Try!(ser.Get(ref size));
	
#if	!BFSERIALIZER_EXCLUDE_RUNTIME_CHECKS
			if (ser.ReadLength < size)
			    return .Err(.NotEnoughData);
			if (size % 2 != 0)
				return .Err(.GenericError);
#endif
	
			size /= 2;
	
			Clear();
			Reserve(size);
	
			if (size == 0)
			    return .Ok;
	
			for (int i < size)
			{
				char16 x = ?;
				Try!(ser.GetMemory(ref x));
				Append(x);
			}
	
			return .Ok;
		}
	}
}