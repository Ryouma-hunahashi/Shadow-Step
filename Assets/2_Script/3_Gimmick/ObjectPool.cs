using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.SceneManagement;

public class ObjectPool : MonoBehaviour
{
    [Header("�v�[���ɓo�^����I�u�W�F�N�g�̃v���n�u")]
    [SerializeField] private GameObject poolObj;
    [Header("�v�[���̏����I�u�W�F�N�g��")]
    [SerializeField] private int initNum = 10;
    private GameObject storeHouse;
    public struct POOL_DATA
    {
        public GameObject obj;
        public bool isUse;
    }
    // �I�u�W�F�N�g�v�[���{��
    private List<POOL_DATA> pool = new List<POOL_DATA>();

    [SerializeField] private Vector3 retirePos = new Vector3(100, 100, 100);

    private void Start()
    {
        if(poolObj == null)
        {
            Debug.LogError("�v�[���ɓo�^����I�u�W�F�N�g��ݒ肵�Ă�������");
        }
        // ��ڂ̃V�[�����擾����
        //Scene scene = SceneManager.GetSceneAt(1);
        
        storeHouse = new GameObject(poolObj.name + "PoolHouse");
        //UnityEngine.SceneManagement.SceneManager.MoveGameObjectToScene(storeHouse,scene);
        // �����I�u�W�F�N�g��ݒ�
        for (int i = 0; i < initNum; i++)
        {
            this.AddPool();
        }
    }

    public void SetParent(Transform _trans)
    {
        storeHouse.transform.parent = _trans;
        storeHouse.transform.parent=null;
    }


    /// <summary>
    /// �v�[�����疢�g�p�̃I�u�W�F�N�g���擾����
    /// </summary>
    /// <returns>�g���Ă��Ȃ��I�u�W�F�N�g</returns>
    public GameObject GetPool()
    {
        // �v�[���̗v�f���J��Ԃ�
        for (int i = 0; i < pool.Count; i++)
        {
            // ���g�p��Ԃł����
            if (!pool[i].isUse)
            {
                // �g�p��Ԃɂ��ēn��
                POOL_DATA data = pool[i];
                data.isUse = true;
                pool[i] = data;

                return pool[i].obj;
            }
        }
        // ������Ȃ������ꍇ
        // �V�����I�u�W�F�N�g�𐶐�
        GameObject getObj = this.AddPool();
        POOL_DATA newData = pool[pool.Count - 1];
        newData.isUse = true;
        pool[pool.Count - 1] = newData;
        return getObj;
    }

    /// <summary>
    /// �g�p���̃I�u�W�F�N�g�𖢎g�p��Ԃɂ���
    /// </summary>
    /// <param name="_obj">�ԋp����I�u�W�F�N�g</param>
    public bool ReturnPool(GameObject _obj)
    {
        // �v�[���̗v�f���J��Ԃ�
        for(int i = 0;i<pool.Count;i++)
        {
            // �������̂��������
            if(pool[i].obj == _obj)
            {
                // ���g�p��Ԃɂ���
                POOL_DATA data = pool[i];
                data.isUse = false;
                pool[i] = data;
                // �ʒu���]��������
                _obj.transform.position = retirePos;
                _obj.transform.rotation = Quaternion.identity;
                // �e���i�[�I�u�W�F�ɕύX
                _obj.transform.parent = storeHouse.transform;
                return true;
            }
        }
        return false;
    }

    /// <summary>
    /// �v�[���ɃI�u�W�F�N�g��ǉ�����
    /// </summary>
    /// <returns>�ǉ������I�u�W�F�N�g</returns>
    private GameObject AddPool()
    {
        // �V�����I�u�W�F�N�g��y���ޕ��ɐ���
        GameObject newObj = Instantiate(poolObj,retirePos,Quaternion.identity);
        
        // ���g�p��Ԃɂ���
        POOL_DATA newData;
        newData.obj = newObj;
        newData.isUse = false;

        // �v�[���ɒǉ�����
        pool.Add(newData);
        newObj.transform.parent = storeHouse.transform;
        return newObj;
    }

    private void OnApplicationQuit()
    {
        pool.Clear();
    }
}
