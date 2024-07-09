using System;
using System.Collections.Generic;
using System.Linq;
using System.Reflection;
using UnityEditor;
using UnityEditor.SceneManagement;
using UnityEngine;
using Object = UnityEngine.Object;

/// <summary>
///   PersistentAmongPlayMode�̏��������ۂɂ���N���X
/// </summary>
[InitializeOnLoad] //�G�f�B�^�[�N�����ɏ����������悤��
public class PersistentAmongPlayModeProcessor
{

    //�G�f�B�^��~���O�̒l���L�^���邽�߂�Dict(InstanceID�ƃt�B�[���h����Key�ɂ��A���̒l��ݒ肷�銴��)
    private static readonly Dictionary<int, Dictionary<string, object>> _valueDictDict = new Dictionary<int, Dictionary<string, object>>();

    //=================================================================================
    //������
    //=================================================================================

    static PersistentAmongPlayModeProcessor()
    {
        //�v���C���[�h���ύX���ꂽ���̏�����ݒ�
        EditorApplication.playModeStateChanged += state => 
        {
            // �v���C���s������
            if(state == PlayModeStateChange.EnteredPlayMode)
            {
                // ���g�������Ă���\������̂Ńv���C���s���ɏ������Ă���
                _valueDictDict.Clear();
            }
            //���ۂɏI��������(�V�[���Đ��O�̒l�ɖ߂�����)�ɁA�ۑ����Ă��l�𔽉f
            else if (state == PlayModeStateChange.EnteredEditMode)
            {
                // �{�^���������ꂽ�ϐ������l�𔽉f����
                ExecuteProcessToAllMonoBehaviour(ApplyValue);
            }
        };

    }

    //�SMonoBehaviour���擾���A�w�肵�����������s����
    private static void ExecuteProcessToAllMonoBehaviour(Action<MonoBehaviour> action)
    {
        Object.FindObjectsOfType(typeof(MonoBehaviour)).ToList().ForEach(o => action((MonoBehaviour)o));
    }

    //=================================================================================
    //����
    //=================================================================================

    //PersistentAmongPlayMode���t���Ă�S�t�B�[���h�ɏ��������s����
    private static void ExecuteProcessToAllPersistentAmongPlayModeField(MonoBehaviour component, Action<FieldInfo> action)
    {
        //Public�Ƃ���ȊO�̃t�B�[���h�ɑ΂��ď��������s
        ExecuteProcessToAllPersistentAmongPlayModeField(component, action, BindingFlags.Instance | BindingFlags.Public | BindingFlags.Static);
        ExecuteProcessToAllPersistentAmongPlayModeField(component, action, BindingFlags.Instance | BindingFlags.NonPublic | BindingFlags.InvokeMethod);
    }

    //PersistentAmongPlayMode���t���Ă�A���ABindingFlags�Ŏw�肵���S�t�B�[���h�ɏ��������s����
    private static void ExecuteProcessToAllPersistentAmongPlayModeField(MonoBehaviour component, Action<FieldInfo> action, BindingFlags bindingFlags)
    {
        //�R���|�[�l���g����S�t�B�[���h���擾
        component.GetType()
          .GetFields(bindingFlags)
          .ToList()
          .ForEach(fieldInfo => {
              //PersistentAmongPlayMode���t���Ă���̂ɂ������������s
              if (fieldInfo.GetCustomAttributes(typeof(PersistentAmongPlayModeAttribute), true).Length != 0)
                  action(fieldInfo); // �����ŃX�N���v�g�̕ϐ������擾���Ă���
          });
    }

    //=================================================================================
    //���f
    //=================================================================================

    //PersistentAmongPlayMode�̑������t�����l�𔽉f
    private static void ApplyValue(MonoBehaviour component)
    {
        //�I���{�^�������������ɑ��݂��Ȃ�����(�V�[���Đ����ɍ폜���ꂽ�Ƃ���)��̓X���[
        if (!_valueDictDict.ContainsKey(component.GetInstanceID()))
        {
            return;
        }

        //�e�t�B�[���h�̒l��ۑ�����Dict���擾
        var valueDict = _valueDictDict[component.GetInstanceID()];

        ExecuteProcessToAllPersistentAmongPlayModeField(component, fieldInfo => 
        {
            // �ϐ�����ۑ�����
            var fieldName = fieldInfo.Name;
            foreach (var key in valueDict.Keys)
            {
                if (key == fieldName)
                {
                    //�l�̔��f
                    fieldInfo.SetValue(component, valueDict[fieldName]);
                }
            }
        });
    }

    //=================================================================================
    //�ۑ�
    //=================================================================================

    public static void SaveValue(MonoBehaviour component,string variableName , object value)
    {
        // �C���X�^���XID��ۑ�����
        int instanceID = component.GetInstanceID();

        // 
        if(!_valueDictDict.ContainsKey(instanceID))
        {
            _valueDictDict[instanceID] = new Dictionary<string, object>();
        }

        // �C���X�^���XID���Q�Ƃ��ĕϐ��̖��O�Ɛ��l��ۑ�����
        var valuedict = _valueDictDict[instanceID];
        valuedict[variableName] = value;

        // �C���X�^���XID�ƕϐ����Ɛ��l��ǉ�����
        _valueDictDict.Add(instanceID, valuedict);
    }
}