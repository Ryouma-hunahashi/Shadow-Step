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
        // ウィンドウを表示
        GetWindow<StaticGUI>();
    }

    private void Awake()
    {
        // クールタイムを保存先から取得
        ControllerStickMover.coolTime = EditorPrefs.GetFloat("coolTime", ControllerStickMover.coolTime);
    }

    private void Update()
    {
        // 変更を更新
        Repaint();
    }

    private void OnGUI()
    {
        // 変更のチェック開始
        EditorGUI.BeginChangeCheck();

        // 表示内容が多い場合にスクロールバーを表示
        scroll = EditorGUILayout.BeginScrollView(scroll);

        // 変数をEditor上に表示
        ControllerStickMover.coolTime = EditorGUILayout.FloatField("coolTime", ControllerStickMover.coolTime);

        // スクロールバーの終了
        EditorGUILayout.EndScrollView();

        // 変更があった場合
        if(EditorGUI.EndChangeCheck())
        {
            // クールタイムの変更値を保存
            EditorPrefs.SetFloat("coolTime", ControllerStickMover.coolTime);
        }
    }
}
