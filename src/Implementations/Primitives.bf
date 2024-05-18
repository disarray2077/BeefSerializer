using System;
using System.Diagnostics;
using BeefSerializer.Helpers;

namespace BeefSerializer
{
	extension Serializer
	{
		[Inline]
		public void Put<T>(T x) where T : struct, INumeric
		{
			if (Endianess != PlatformEndianess)
				PutMemory(ByteOrder.SwapNumber(x));
			else
				PutMemory(x);
		}
	
		[Inline]
		public SerializerResult Get<T>(ref T x) where T : struct, INumeric
		{
			let result = GetMemory(ref x);
			if (Endianess != PlatformEndianess && result case .Ok)
				ByteOrder.SwapNumber(ref x);
			return result;
		}
	
		[Inline]
		public void Put<T>(T x) where T : struct, IFloating
		{
			if (Endianess != PlatformEndianess)
				PutMemory(ByteOrder.SwapNumber(x));
			else
				PutMemory(x);
		}
	
		[Inline]
		public SerializerResult Get<T>(ref T x) where T : struct, IFloating
		{
			let result = GetMemory(ref x);
			if (Endianess != PlatformEndianess && result case .Ok)
				ByteOrder.SwapNumber(ref x);
			return result;
		}
		[Inline]
		public void Put<T>(T x) where T : struct, ICharacter
		{
			if (Endianess != PlatformEndianess)
				PutMemory(ByteOrder.SwapNumber(x));
			else
				PutMemory(x);
		}
	
		[Inline]
		public SerializerResult Get<T>(ref T x) where T : struct, ICharacter
		{
			let result = GetMemory(ref x);
			if (Endianess != PlatformEndianess && result case .Ok)
				ByteOrder.SwapNumber(ref x);
			return result;
		}
	
		[Inline]
		public void Put(bool x)
		{
	#unwarn
			Debug.Assert(*((uint8*)&x) <= 1);
			PutMemory(x);
		}
	
		[Inline]
		public SerializerResult Get(ref bool x)
		{
	#if !BFSERIALIZER_EXCLUDE_RUNTIME_CHECKS
			let result = GetMemory(ref x);
			if (*((uint8*)&x) > 1 && result case .Ok)
				return .Err(.GenericError);
			return result;
	#else
			return GetMemory(ref x);
	#endif
		}
	}
}