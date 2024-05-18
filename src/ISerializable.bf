using System.IO;

namespace BeefSerializer
{
	public interface ISerializable
	{
		concrete void Serialize(Serializer ser);
		concrete SerializerResult Deserialize(Serializer ser) mut;
	}
}
