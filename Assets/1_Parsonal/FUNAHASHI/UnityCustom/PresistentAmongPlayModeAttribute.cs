using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using System;

/// <summary>
/// エディタ再生中に変更した値をエディタ停止後もそのまま保持する属性
/// </summary>
[AttributeUsage(AttributeTargets.Field)]
public class PersistentAmongPlayModeAttribute : PropertyAttribute { }