using System;
using System.Diagnostics;

namespace BeefSerializer.Helpers
{
	public static class ByteOrder
	{
		[Inline]
		public static void SwapNumber<T>(ref T x) where T : var
		{
			switch (sizeof(T))
			{
			case 2:
				x = (T)SwapInt16((uint16)x);
			case 4:
				if (typeof(T) == typeof(float))
					x = (T)SwapFloat((float)x);
				else
					x = (T)SwapInt32((uint32)x);
			case 8:
				if (typeof(T) == typeof(double))
					x = (T)SwapDouble((double)x);
				else
					x = (T)SwapInt64((uint64)x);
			default:
				Debug.Assert(sizeof(T) == 1);
			}
		}

		[Inline]
		public static T SwapNumber<T>(T x) where T : var
		{
			var x;
			SwapNumber(ref x);
			return x;
		}

		[Inline]
		public static uint16 SwapInt16(uint16 x)
		{
			return ((x & 0xFF) << 8) | ((x >> 8) & 0xFF);
		}
		
		[Inline]
		public static uint32 SwapInt32(uint32 x)
		{
			var x;
			// swap adjacent 16-bit blocks
			x = (x >> 16) | (x << 16);
			// swap adjacent 8-bit blocks
			return ((x & 0xFF00FF00) >> 8) | ((x & 0x00FF00FF) << 8);
		}
		
		[Inline]
		public static uint64 SwapInt64(uint64 x)
		{
			var x;
		    // swap adjacent 32-bit blocks
		    x = (x >> 32) | (x << 32);
		    // swap adjacent 16-bit blocks
		    x = ((x & 0xFFFF0000FFFF0000) >> 16) | ((x & 0x0000FFFF0000FFFF) << 16);
		    // swap adjacent 8-bit blocks
		    return ((x & 0xFF00FF00FF00FF00) >> 8) | ((x & 0x00FF00FF00FF00FF) << 8);
		}
		
		[Inline]
		public static float SwapFloat(float x)
		{
			var x;
			uint32 i = SwapInt32(*((uint32*)&x));
			return *((float*)&i);
		}
		
		[Inline]
		public static double SwapDouble(double x)
		{
			var x;
			uint64 i = SwapInt64(*((uint64*)&x));
			return *((double*)&i);
		}
	}
}
