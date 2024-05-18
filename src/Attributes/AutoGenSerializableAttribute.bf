using System;

namespace BeefSerializer
{
	[AttributeUsage(.Class | .Struct)]
	public struct AutoGenSerializableAttribute : Attribute, IComptimeTypeApply
	{
		public enum InclusionType
		{
			OptIn,
			OptOut
		}

		public InclusionType mInclusionType;

		public this(InclusionType inclusionType = .OptOut)
		{
			mInclusionType = inclusionType;
		}

		[Comptime]
		public void GenSerialize(Type type)
		{
			String result = scope .();
			result.Append("public void ISerializable.Serialize(Serializer ser)");
			result.Append("\n{");

			for (var field in type.GetFields())
			{
				if (field.DeclaringType == typeof(Object))
					continue;
				if (field.IsStatic || field.IsConst)
					continue;
				if (mInclusionType == .OptOut)
				{
					if (field.HasCustomAttribute<HideSerializableAttribute>())
						continue;
				}
				else
				{
					if (!field.HasCustomAttribute<SerializableAttribute>())
						continue;
				}
				if (field.HasCustomAttribute<ForceSerializeSizeAttribute>())
				{
					result.Append("\n\t");
					result.AppendF($"ser.Put((uint32)this.{field.Name}.Count);");
				}
				if (field.HasCustomAttribute<RawMemoryAttribute>())
				{
					result.Append("\n\t");
					result.AppendF($"ser.PutMemory(.((uint8*)this.{field.Name}.Ptr, this.{field.Name}.Count));");
				}
				else
				{
					result.Append("\n\t");
					result.AppendF($"ser.Put(this.{field.Name});");
				}
			}

			result.Append("\n}\n");

			Compiler.EmitTypeBody(type, result);
		}

		[Comptime]
		public void GenDeserialize(Type type)
		{
			String result = scope .();
			result.Append("public SerializerResult ISerializable.Deserialize(Serializer ser)");
			if (type.IsStruct)
				result.Append(" mut");
			result.Append("\n{");

			for (var field in type.GetFields())
			{
				if (field.DeclaringType == typeof(Object))
					continue;
				if (field.IsStatic || field.IsConst)
					continue;
				if (mInclusionType == .OptOut)
				{
					if (field.HasCustomAttribute<HideSerializableAttribute>())
						continue;
				}
				else
				{
					if (!field.HasCustomAttribute<SerializableAttribute>())
						continue;
				}
				if (field.HasCustomAttribute<ForceSerializeSizeAttribute>())
				{
					result.Append("\n\t");
					result.Append("ser.Buffer.Position += 4;");
				}
				result.Append("\n\t");
				result.AppendF($"Try!(ser.Get(ref this.{field.Name}));");
			}

			result.Append("\n\treturn .Ok;");
			result.Append("\n}\n");

			Compiler.EmitTypeBody(type, result);
		}

		[Comptime]
		public void ApplyToType(Type type)
		{
			Compiler.EmitAddInterface(type, typeof(ISerializable));
			GenSerialize(type);
			GenDeserialize(type);
		}
	}
}
