using System;

namespace BeefSerializer;

[AttributeUsage(.Field)]
struct RawMemoryAttribute : Attribute
{
}