using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class ShadowHitChecker : MonoBehaviour
{
    // 当たっている影のオブジェリスト
    private List<Transform> hitShadowTransforms = new List<Transform>();
    // 当たっている影のマネージャーオブジェクト
    private List<Transform> hitManagerTransforms = new List<Transform>();



    /// <summary>
    /// 引数のマネージャーオブジェクトがこのポイントに当たっているかを確認
    /// </summary>
    /// <param name="trans">マネージャーのトランスフォーム</param>
    /// <returns></returns>
    public bool CheckHitTrans(Transform trans)
    {
        for(int i = 0; i < hitManagerTransforms.Count; i++)
        {
            if(hitManagerTransforms[i] == trans)
            {
                return true;
            }
        }
        return false;
    }

    /// <summary>
    /// 引数の影オブジェクトがこのポイントに当たっているかを確認
    /// </summary>
    /// <param name="trans">影のトランスフォーム</param>
    /// <returns></returns>
    public bool CheckHitShadow(Transform trans)
    {
        for (int i = 0; i < hitShadowTransforms.Count; i++)
        {
            if (hitShadowTransforms[i] == trans)
            {
                return true;
            }
        }
        return false;
    }

    public int CountHit() { return hitManagerTransforms.Count; }

    public Transform[] GetAllHitShadows() { return hitShadowTransforms.ToArray(); }
    public Transform[] GetAllHitManagers() { return hitManagerTransforms.ToArray(); }

    private void LateUpdate()
    {
        // とりあえず整理前にマネージャーはリセット
        hitManagerTransforms.Clear();
        // ヒットしている影の分繰り返す
        for (int i = hitShadowTransforms.Count - 1; i >= 0; i--)
        {
            // もし、使われていない影があれば排除する
            if (hitShadowTransforms[i].parent.parent == null)
            {
                hitShadowTransforms[i] = hitShadowTransforms[hitShadowTransforms.Count - 1];
                hitShadowTransforms.RemoveAt(hitShadowTransforms.Count - 1);
            }
        }

        // この時点で登録されていなければ抜ける
        if (hitShadowTransforms.Count == 0) { return; }

        // 一つ目は被りようがないので登録
        hitManagerTransforms.Add(hitShadowTransforms[0].parent.parent);
        // 当たっている影分繰り返す
        for (int j = 1; j < hitShadowTransforms.Count; j++)
        {
            // 登録可能かをチェック
            bool search = true;
            for (int i = 0; i < hitManagerTransforms.Count; i++)
            {
                // 同じマネージャーがあれば登録負荷
                if (hitShadowTransforms[j].parent.parent == hitManagerTransforms[i])
                {
                    search = false;
                    break;
                }
            }
            if (search)
            {
                hitManagerTransforms.Add(hitShadowTransforms[j].parent.parent);
            }
        }
    }

    private void OnTriggerEnter(Collider other)
    {
        // 当たっているのが影でなければ処理を終える
        if (!other.gameObject.CompareTag("Shadow")) { return; }
        // 親の親を取得
        // 当たったトランスフォームを取得
        Transform otherTrans = other.transform;
        // 親の親がいなければ処理を終える
        if (otherTrans.parent.parent == null) { return; }

        // 登録可能かをチェック
        bool search = true;
        for (int i = 0; i < hitShadowTransforms.Count; i++)
        {
            // 同じ影があれば登録負荷
            if (hitShadowTransforms[i] == otherTrans)
            {
                search = false;
                break;
            }
        }
        if(search)
        {
            hitShadowTransforms.Add(otherTrans);
        }

    }

    private void OnTriggerExit(Collider other)
    {
        // 影でなければ処理を終える
        if (!other.gameObject.CompareTag("Shadow")) { return; }

        // 影のトランスフォームを取得
        Transform otherTrans = other.transform;
        for (int i = 0; i < hitShadowTransforms.Count; i++)
        {
            // 同じものがあればヒット履歴から外す
            if (hitShadowTransforms[i] == otherTrans)
            {
                hitShadowTransforms[i] = hitShadowTransforms[hitShadowTransforms.Count - 1];
                hitShadowTransforms.RemoveAt(hitShadowTransforms.Count - 1);
                break;
            }
        }
    }
}
