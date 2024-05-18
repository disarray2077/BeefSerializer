using System;

namespace BeefSerializer;

[AttributeUsage(.Field)]
struct HideSerializableAttribute : Attribute
{
}