using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;
using System.Reflection;
using System;
/// <summary>
/// PersistentAmongPlayModeAttribute�̑�����t�^��������Inspector�̕\����ς��邽�߂̃N���X
/// </summary>
[CustomPropertyDrawer(typeof(PersistentAmongPlayModeAttribute))]
public class PersistentAmongPlayModeDrawer : PropertyDrawer
{

    /// <summary>
    /// GUI�̍������擾
    /// </summary>
    public override float GetPropertyHeight(SerializedProperty property, GUIContent label)
    {
        //�ʏ���3�{�̍������m��(EditorGUIUtility.singleLineHeight�͈�s�̃f�t�H���g�̍���)
        return EditorGUIUtility.singleLineHeight * 2;
    }

    ///// <summary>
    ///// GUI�̕\���ݒ�z
    ///// </summary>
    public override void OnGUI(Rect position, SerializedProperty property, GUIContent label)
    {
        // �v���p�e�B�̈ʒu�ƃT�C�Y��ݒ�
        var size = new Vector2(0, EditorGUIUtility.singleLineHeight);
        position.size = position.size - size;
        // �v���p�e�B��\��
        var buttonWidth = 40f;
        var fieldWidth = position.width - buttonWidth;
        var fieldRect = new Rect(position.x, position.y, fieldWidth, EditorGUIUtility.singleLineHeight);
        EditorGUI.PropertyField(fieldRect, property, label);

        // �{�^����Rect��ݒ�
        var buttonRect = new Rect(position.x + fieldWidth, position.y, buttonWidth, EditorGUIUtility.singleLineHeight);
        // �{�^����\�����āA�N���b�N���̏������L�q
        if (GUI.Button(buttonRect, "Save"))
        {
            //PersistentAmongPlayModeProcessor._valueDict.Add()
            // �v���p�e�B�����I�u�W�F�N�g�� MonoBehaviour �ł��邱�Ƃ��m�F���A���̏ꍇ�ɕۑ����������s
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