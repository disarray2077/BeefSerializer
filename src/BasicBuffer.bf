using System;
using System.Collections;
using System.Diagnostics;

namespace BeefSerializer
{
	class BasicBuffer
	{
		private List<uint8> mBuffer ~ delete _;
		private int mReadOffset;

		public uint8* Ptr => mBuffer.IsEmpty ? null : mBuffer.Ptr;
		public int Length => mBuffer.Count;
		public int ReadLength => mBuffer.Count - mReadOffset;

		public int Position
		{
			get => mReadOffset;
			set => mReadOffset = value;
		}

		public int Capacity
		{
			get => mBuffer.Capacity;
			set => mBuffer.Capacity = value;
		}

		public this()
		{
			mBuffer = new .();
			mReadOffset = 0;
		}

		public this(int capacity)
		{
			mBuffer = new .(capacity);
			mReadOffset = 0;
		}

		public void Clear()
		{
			mBuffer.Clear();
			mReadOffset = 0;
		}
		
		[Inline]
		public void Reset()
		{
			mReadOffset = 0;
		}
		
		[Inline]
		public void CopyTo(BasicBuffer other)
		{
			other.mReadOffset = mReadOffset;
			mBuffer.CopyTo(other.mBuffer);
		}

		[Inline]
		public void CopyTo(List<uint8> other)
		{
			mBuffer.CopyTo(other);
		}

		[Inline]
		public bool Write(uint8* data, int len)
		{
			Debug.Assert(data != null);
			Debug.Assert(len > 0);

			Internal.MemCpy(mBuffer.GrowUnitialized(len), data, len);
			return true;
		}

		[Inline]
		public bool Read(uint8* dataOut, int len)
		{
			Debug.Assert(dataOut != null);
			Debug.Assert(len > 0);

#if !BFSERIALIZER_EXCLUDE_RUNTIME_CHECKS
			if (len > (mBuffer.Count - mReadOffset))
				return false;
#endif

			Internal.MemCpy(dataOut, mBuffer.Ptr + mReadOffset, len);
			mReadOffset += len;
			return true;
		}

		[Inline]
		public Result<int> TryRead(Span<uint8> data)
		{
			if (!Read(data.Ptr, data.Length))
				return .Err;
			return .Ok(data.Length);
		}

		[Inline]
		public Result<int> TryWrite(Span<uint8> data)
		{
			if (!Write(data.Ptr, data.Length))
				return .Err;
			return .Ok(data.Length);
		}
	}
}