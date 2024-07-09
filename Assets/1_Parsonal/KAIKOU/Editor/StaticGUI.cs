using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;

//[CustomEditor(typeof(MonoBehaviour),true)]
public class StaticGUI
    : EditorWindow
{
    private Vector2 scroll;

    [MenuItem("Custom tools/StaticGUI")]
    static void ShowWindow()
    {
        // �E�B���h�E��\��
        GetWindow<StaticGUI>();
    }

    private void Awake()
    {
        // �N�[���^�C����ۑ��悩��擾
        ControllerStickMover.coolTime = EditorPrefs.GetFloat("coolTime", ControllerStickMover.coolTime);
    }

    private void Update()
    {
        // �ύX���X�V
        Repaint();
    }

    private void OnGUI()
    {
        // �ύX�̃`�F�b�N�J�n
        EditorGUI.BeginChangeCheck();

        // �\�����e�������ꍇ�ɃX�N���[���o�[��\��
        scroll = EditorGUILayout.BeginScrollView(scroll);

        // �ϐ���Editor��ɕ\��
        ControllerStickMover.coolTime = EditorGUILayout.FloatField("coolTime", ControllerStickMover.coolTime);

        // �X�N���[���o�[�̏I��
        EditorGUILayout.EndScrollView();

        // �ύX���������ꍇ
        if(EditorGUI.EndChangeCheck())
        {
            // �N�[���^�C���̕ύX�l��ۑ�
            EditorPrefs.SetFloat("coolTime", ControllerStickMover.coolTime);
        }
    }
}
