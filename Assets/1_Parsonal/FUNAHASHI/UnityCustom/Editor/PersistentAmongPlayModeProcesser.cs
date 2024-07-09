using System;
using System.Collections.Generic;
using System.Linq;
using System.Reflection;
using UnityEditor;
using UnityEditor.SceneManagement;
using UnityEngine;
using Object = UnityEngine.Object;

/// <summary>
///   PersistentAmongPlayModeの処理を実際にするクラス
/// </summary>
[InitializeOnLoad] //エディター起動時に初期化されるように
public class PersistentAmongPlayModeProcessor
{

    //エディタ停止直前の値を記録するためのDict(InstanceIDとフィールド名をKeyにし、その値を設定する感じ)
    private static readonly Dictionary<int, Dictionary<string, object>> _valueDictDict = new Dictionary<int, Dictionary<string, object>>();

    //=================================================================================
    //初期化
    //=================================================================================

    static PersistentAmongPlayModeProcessor()
    {
        //プレイモードが変更された時の処理を設定
        EditorApplication.playModeStateChanged += state => 
        {
            // プレイ実行した時
            if(state == PlayModeStateChange.EnteredPlayMode)
            {
                // 中身が入っている可能性あるのでプレイ実行時に消去しておく
                _valueDictDict.Clear();
            }
            //実際に終了した時(シーン再生前の値に戻った時)に、保存してた値を反映
            else if (state == PlayModeStateChange.EnteredEditMode)
            {
                // ボタンを押された変数だけ値を反映する
                ExecuteProcessToAllMonoBehaviour(ApplyValue);
            }
        };

    }

    //全MonoBehaviourを取得し、指定した処理を実行する
    private static void ExecuteProcessToAllMonoBehaviour(Action<MonoBehaviour> action)
    {
        Object.FindObjectsOfType(typeof(MonoBehaviour)).ToList().ForEach(o => action((MonoBehaviour)o));
    }

    //=================================================================================
    //共通
    //=================================================================================

    //PersistentAmongPlayModeが付いてる全フィールドに処理を実行する
    private static void ExecuteProcessToAllPersistentAmongPlayModeField(MonoBehaviour component, Action<FieldInfo> action)
    {
        //Publicとそれ以外のフィールドに対して処理を実行
        ExecuteProcessToAllPersistentAmongPlayModeField(component, action, BindingFlags.Instance | BindingFlags.Public | BindingFlags.Static);
        ExecuteProcessToAllPersistentAmongPlayModeField(component, action, BindingFlags.Instance | BindingFlags.NonPublic | BindingFlags.InvokeMethod);
    }

    //PersistentAmongPlayModeが付いてる、かつ、BindingFlagsで指定した全フィールドに処理を実行する
    private static void ExecuteProcessToAllPersistentAmongPlayModeField(MonoBehaviour component, Action<FieldInfo> action, BindingFlags bindingFlags)
    {
        //コンポーネントから全フィールドを取得
        component.GetType()
          .GetFields(bindingFlags)
          .ToList()
          .ForEach(fieldInfo => {
              //PersistentAmongPlayModeが付いてるものにだけ処理を実行
              if (fieldInfo.GetCustomAttributes(typeof(PersistentAmongPlayModeAttribute), true).Length != 0)
                  action(fieldInfo); // ここでスクリプトの変数名を取得している
          });
    }

    //=================================================================================
    //反映
    //=================================================================================

    //PersistentAmongPlayModeの属性が付いた値を反映
    private static void ApplyValue(MonoBehaviour component)
    {
        //終了ボタンを押した時に存在しなかった(シーン再生中に削除されたとかで)やつはスルー
        if (!_valueDictDict.ContainsKey(component.GetInstanceID()))
        {
            return;
        }

        //各フィールドの値を保存したDictを取得
        var valueDict = _valueDictDict[component.GetInstanceID()];

        ExecuteProcessToAllPersistentAmongPlayModeField(component, fieldInfo => 
        {
            // 変数名を保存する
            var fieldName = fieldInfo.Name;
            foreach (var key in valueDict.Keys)
            {
                if (key == fieldName)
                {
                    //値の反映
                    fieldInfo.SetValue(component, valueDict[fieldName]);
                }
            }
        });
    }

    //=================================================================================
    //保存
    //=================================================================================

    public static void SaveValue(MonoBehaviour component,string variableName , object value)
    {
        // インスタンスIDを保存する
        int instanceID = component.GetInstanceID();

        // 
        if(!_valueDictDict.ContainsKey(instanceID))
        {
            _valueDictDict[instanceID] = new Dictionary<string, object>();
        }

        // インスタンスIDを参照して変数の名前と数値を保存する
        var valuedict = _valueDictDict[instanceID];
        valuedict[variableName] = value;

        // インスタンスIDと変数名と数値を追加する
        _valueDictDict.Add(instanceID, valuedict);
    }
}