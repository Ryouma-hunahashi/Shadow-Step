using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.SceneManagement;

public class ObjectPool : MonoBehaviour
{
    [Header("プールに登録するオブジェクトのプレハブ")]
    [SerializeField] private GameObject poolObj;
    [Header("プールの初期オブジェクト数")]
    [SerializeField] private int initNum = 10;
    private GameObject storeHouse;
    public struct POOL_DATA
    {
        public GameObject obj;
        public bool isUse;
    }
    // オブジェクトプール本体
    private List<POOL_DATA> pool = new List<POOL_DATA>();

    [SerializeField] private Vector3 retirePos = new Vector3(100, 100, 100);

    private void Start()
    {
        if(poolObj == null)
        {
            Debug.LogError("プールに登録するオブジェクトを設定してください");
        }
        // 二つ目のシーンを取得する
        //Scene scene = SceneManager.GetSceneAt(1);
        
        storeHouse = new GameObject(poolObj.name + "PoolHouse");
        //UnityEngine.SceneManagement.SceneManager.MoveGameObjectToScene(storeHouse,scene);
        // 初期オブジェクトを設定
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
    /// プールから未使用のオブジェクトを取得する
    /// </summary>
    /// <returns>使われていないオブジェクト</returns>
    public GameObject GetPool()
    {
        // プールの要素分繰り返す
        for (int i = 0; i < pool.Count; i++)
        {
            // 未使用状態であれば
            if (!pool[i].isUse)
            {
                // 使用状態にして渡す
                POOL_DATA data = pool[i];
                data.isUse = true;
                pool[i] = data;

                return pool[i].obj;
            }
        }
        // 見つからなかった場合
        // 新しいオブジェクトを生成
        GameObject getObj = this.AddPool();
        POOL_DATA newData = pool[pool.Count - 1];
        newData.isUse = true;
        pool[pool.Count - 1] = newData;
        return getObj;
    }

    /// <summary>
    /// 使用中のオブジェクトを未使用状態にする
    /// </summary>
    /// <param name="_obj">返却するオブジェクト</param>
    public bool ReturnPool(GameObject _obj)
    {
        // プールの要素分繰り返す
        for(int i = 0;i<pool.Count;i++)
        {
            // 同じものが見つかれば
            if(pool[i].obj == _obj)
            {
                // 未使用状態にする
                POOL_DATA data = pool[i];
                data.isUse = false;
                pool[i] = data;
                // 位置や回転を初期化
                _obj.transform.position = retirePos;
                _obj.transform.rotation = Quaternion.identity;
                // 親を格納オブジェに変更
                _obj.transform.parent = storeHouse.transform;
                return true;
            }
        }
        return false;
    }

    /// <summary>
    /// プールにオブジェクトを追加する
    /// </summary>
    /// <returns>追加したオブジェクト</returns>
    private GameObject AddPool()
    {
        // 新しいオブジェクトを遥か彼方に生成
        GameObject newObj = Instantiate(poolObj,retirePos,Quaternion.identity);
        
        // 未使用状態にする
        POOL_DATA newData;
        newData.obj = newObj;
        newData.isUse = false;

        // プールに追加する
        pool.Add(newData);
        newObj.transform.parent = storeHouse.transform;
        return newObj;
    }

    private void OnApplicationQuit()
    {
        pool.Clear();
    }
}
