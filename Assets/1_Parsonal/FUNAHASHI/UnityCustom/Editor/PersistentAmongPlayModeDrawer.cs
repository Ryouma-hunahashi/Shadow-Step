using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;
using System.Reflection;
using System;
/// <summary>
/// PersistentAmongPlayModeAttributeの属性を付与した時のInspectorの表示を変えるためのクラス
/// </summary>
[CustomPropertyDrawer(typeof(PersistentAmongPlayModeAttribute))]
public class PersistentAmongPlayModeDrawer : PropertyDrawer
{

    /// <summary>
    /// GUIの高さを取得
    /// </summary>
    public override float GetPropertyHeight(SerializedProperty property, GUIContent label)
    {
        //通常より3倍の高さを確保(EditorGUIUtility.singleLineHeightは一行のデフォルトの高さ)
        return EditorGUIUtility.singleLineHeight * 2;
    }

    ///// <summary>
    ///// GUIの表示設定z
    ///// </summary>
    public override void OnGUI(Rect position, SerializedProperty property, GUIContent label)
    {
        // プロパティの位置とサイズを設定
        var size = new Vector2(0, EditorGUIUtility.singleLineHeight);
        position.size = position.size - size;
        // プロパティを表示
        var buttonWidth = 40f;
        var fieldWidth = position.width - buttonWidth;
        var fieldRect = new Rect(position.x, position.y, fieldWidth, EditorGUIUtility.singleLineHeight);
        EditorGUI.PropertyField(fieldRect, property, label);

        // ボタンのRectを設定
        var buttonRect = new Rect(position.x + fieldWidth, position.y, buttonWidth, EditorGUIUtility.singleLineHeight);
        // ボタンを表示して、クリック時の処理を記述
        if (GUI.Button(buttonRect, "Save"))
        {
            //PersistentAmongPlayModeProcessor._valueDict.Add()
            // プロパティを持つオブジェクトが MonoBehaviour であることを確認し、その場合に保存処理を実行
            MonoBehaviour monoBehaviour = property.serializedObject.targetObject as MonoBehaviour;
            Debug.Log(monoBehaviour);
            if (monoBehaviour != null)
            {

                string variablename = property.name;
                
                string key = $"{monoBehaviour.GetType().FullName}_{variablename}";
                Debug.Log(key);
                Debug.Log(property.boxedValue);
                PersistentAmongPlayModeProcessor.SaveValue(monoBehaviour, variablename, property.boxedValue);
                
            }
        }
    }
}