using System;
using System.IO;
using System.Text;
using System.Diagnostics;
using BeefSerializer.Helpers;

namespace BeefSerializer
{
	public typealias SerializerResult = Result<void, ErrorType>;

	public enum ErrorType
	{
		/// Unexpected error
		GenericError,
		/// Unexpected error during stream reading
		IOError,
		/// Reached end of stream unexpectedly
		NotEnoughData,
	}

	public enum Endianess
	{
		BigEndian,
		LittleEndian
	}

	public class Serializer
	{
		private BasicBuffer mBuffer ~ if (mOwnsBuffer) delete _;
		private bool mOwnsBuffer;
		private Encoding mEncoding;
		private IRawAllocator mAllocator;

		public BasicBuffer Buffer => mBuffer;
		public int64 ReadLength => mBuffer.Length - mBuffer.Position;
		public IRawAllocator Allocator => mAllocator;

#if !BFSERIALIZER_NO_NULLSIGN_SUPPORT
		public const bool UseNullSign = true;
#else
		public const bool UseNullSign = false;
#endif

#if BF_LITTLE_ENDIAN
		private const Endianess PlatformEndianess = .LittleEndian;
#else
		private const Endianess PlatformEndianess = .BigEndian;
#endif

#if BFSERIALIZER_FORCE_PLATFORM_ENDIAN
		public const Endianess Endianess = PlatformEndianess;
#elif BFSERIALIZER_FORCE_LITTLE_ENDIAN
		public const Endianess Endianess = .LittleEndian;
#elif BFSERIALIZER_FORCE_BIG_ENDIAN
		public const Endianess Endianess = .BigEndian;
#else
		public Endianess Endianess = PlatformEndianess;
#endif

		public this(BasicBuffer buffer, bool ownsBuffer = false) : this(buffer, Encoding.UTF8, ownsBuffer)
		{
		}

		public this(BasicBuffer buffer, Encoding encoding, bool ownsBuffer = false)
		{
			Debug.Assert(buffer != null);

			mBuffer = buffer;
			mEncoding = encoding;
			mOwnsBuffer = ownsBuffer;
		}

		public this(BasicBuffer buffer, IRawAllocator allocator, bool ownsBuffer = false)
		{
			Debug.Assert(buffer != null);

			mBuffer = buffer;
			mAllocator = allocator;
			mOwnsBuffer = ownsBuffer;
		}

		public this(BasicBuffer buffer, Encoding encoding, IRawAllocator allocator, bool ownsBuffer = false)
		{
			Debug.Assert(buffer != null);

			mBuffer = buffer;
			mEncoding = encoding;
			mAllocator = allocator;
			mOwnsBuffer = ownsBuffer;
		}

		public mixin PutNullSign(var x)
		{
#if !BFSERIALIZER_NO_NULLSIGN_SUPPORT
			if (UseNullSign)
			{
				if (IsNullStrict(x)) // Beef's default null checking is a warning for non-nullable types...
				{
					Put(true);
					return;
				}

				Put(false);
			}
#endif
		}

		public mixin GetNullSign(var x)
		{
#if !BFSERIALIZER_NO_NULLSIGN_SUPPORT
			if (UseNullSign)
			{
				bool isNull = ?;
				Try!(Get(ref isNull));

				if (isNull)
				{
					if (typeof(decltype(x)).IsObject) [ConstSkip]
					{
						System.Diagnostics.Debug.AssertNotStack(x);
						delete x;
					}
					x = null;
					return SerializerResult.Ok;
				}
			}
#endif
		}

		[Inline]
		public void Put<T>(T x) where T : ISerializable
		{
			x.Serialize(this);
		}

		[Inline]
		public SerializerResult Get<T>(ref T x) where T : ISerializable
		{
			return x.Deserialize(this);
		}

		[Inline]
		public SerializerResult Get<T>(ref T x) where T : ISerializable
			where T : class, new
		{
			if (x == null)
			{
				if (mAllocator != null)
					x = new:mAllocator .();
				else
					x = new .();
			}
			return x.Deserialize(this);
		}

		[Inline]
		public void PutMemory<T>(T x) where T : struct
		{
#unwarn
			PutMemory(.((uint8*)&x, sizeof(T)));
		}

		[Inline]
		public SerializerResult GetMemory<T>(ref T x) where T : struct
		{
			return GetMemory(.((uint8*)&x, sizeof(T)));
		}
		
		[Inline]
		public virtual void PutMemory(Span<uint8> data)
		{
			Debug.Assert(Buffer != null);
		    Debug.Assert(data.Ptr != null);

			let result = Buffer.Write(data.Ptr, data.Length);

			// This should never fail, but let's check anyway.
			Debug.Assert(result);
		}

		[Inline]
		public virtual SerializerResult GetMemory(Span<uint8> data)
		{
			Debug.Assert(Buffer != null);
		    Debug.Assert(data.Ptr != null);

#if !BFSERIALIZER_EXCLUDE_RUNTIME_CHECKS
			if (Buffer.TryRead(data) case .Ok(let read))
				return read == data.Length ? .Ok : .Err(.NotEnoughData);

			return ReadLength < data.Length ? .Err(.NotEnoughData) : .Err(.IOError);
#else
			Buffer.TryRead(data).IgnoreError();
			return .Ok;
#endif
		}
	}
}
