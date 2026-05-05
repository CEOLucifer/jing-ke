using System.Collections.Generic;

/// <summary>
/// 装备
/// </summary>
public partial class Equipment : Item
{
    public EType type;
    public List<Word> words;

    /// <summary>
    /// 装备类型
    /// </summary>
    public enum EType
    {
        Head,
        Necklace,
        Body,
        LeftHand,
        RightHand,
        LeftRing,
        RightRing,
        Belt,
        Pants,
        Shoes,

        /// <summary>
        /// 空。！！！确保这个枚举值在最后一个
        /// </summary>
        None,
    }

}