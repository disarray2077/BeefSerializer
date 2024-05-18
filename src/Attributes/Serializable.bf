using System;

namespace BeefSerializer;

[AttributeUsage(.Field)]
struct SerializableAttribute : Attribute
{
}