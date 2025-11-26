<?php
/**
 * EasyDocList
 *
 * リストを簡単に作成するためのスニペット。
 *
 * @category snippet
 * @version  0.1.0
 * @license  GNU General Public License (GPL), https://www.gnu.org/licenses/gpl-3.0.html
 * @author   Yu.No (https://github.com/yuno25211415)
 * @internal @properties &
 * @internal @modx_category Custom
 * @internal @installset base, sample
 * @param string &parents 基準となる親リソースのID
 * @param string &documents 繰り返すリソースのID（カンマ区切りで指定）
 * @param string &filters 条件を指定して絞り込む
 * @param integer &maxDepth 対象となるサブリソースの最大の深さ（-1で無制限）
 * @param integer &publicState 公開を対象とするか非公開を対象とするか（1 = 公開　0 = 非公開　-1 = 両方）
 * @param integer &ignoreHidden 「メニューに表示」項目で非表示としているリソースを除外するかどうか
 * @param string &sort リストの並び順
 * @param integer &display 表示する件数（-1 = 無制限）
 * @param string &tvPrefix テンプレート変数の接頭辞
 * @param string &outerTpl リストアイテムを囲うHTMLテンプレート
 * @param string &rowTpl リストアイテムのHTMLテンプレート
 * @param string &noResults 1件もないときに表示するHTMLテンプレート
 * @example [[EasyDocList? &parents=`13`]]
 * @example [[EasyDocList? &documents=`13,117`]]
 */

// パラメーターの初期設定
if (!isset($filters)) $filters = '';
if (!isset($maxDepth)) $maxDepth = 1;
if (!isset($publicState)) $publicState = 1;
if (!isset($ignoreHidden)) $ignoreHidden = 1;
if (!isset($sort)) $sort = 'menuindex ASC, id ASC';
if (!isset($display)) $display = -1;
if (!isset($tvPrefix)) $tvPrefix = 'tv.';
if (!isset($outerTpl)) $outerTpl = '@CODE:<ul>[+wrap+]</ul>';
if (!isset($rowTpl)) $rowTpl = '@CODE:<li><a href="[+url+]">[+title+]</a>[+wrap+]</li>';
if (!isset($noResults)) $noResults = '';

if ($maxDepth == 0) return '';

$snippetName = $modx->getSnippetName();

if (!isset($parents) && !isset($documents)) {
	$parents = (string)$modx->documentIdentifier;
	// evo()->addLog('['.$snippetName.'] 指定なし: '.$parents);
}

if (preg_match('/^[0-9]+$/', $parents)) $parents = (int)$parents;

// evo()->addLog('['.$snippetName.'] parents: '.$parents, gettype($parents));
// evo()->addLog('['.$snippetName.'] documents: '.$documents, gettype($parents));

// 条件
$wheres = [
	['hidemenu', '=', $ignoreHidden == 1 ? 0 : 1]
];

if ($publicState != -1) $wheres[] = ['published', '=', $publicState];

$orWheres = [];

if (!empty($filters)) {
	if (preg_match('/^(AND|OR)\(([^)]+)\);?$/', trim($filters), $conditions)) {
		// evo()->addLog('['.$snippetName.'] filters', $matches);

		$addWheres = [];

		foreach (explode(';', $conditions[2]) as $condition) {
			list($from, $operator, $to) = explode(':', $condition);

			evo()->addLog('['.$snippetName.'] filters', [
				'from'     => $from,
				'operator' => $operator,
				'to'       => $to
			]);

			if ($conditions[1] === 'AND') {
				$wheres[] = [$from, $operator, $to];
			} else {
				$orWheres[] = [$from, $operator, $to];
			}
		}
	}
}

// 直下全てのリソースの情報を取得
if (isset($parents) && (!empty($parents) || $parents === 0)) {
	// evo()->addLog('['.$snippetName.'] 直下全てのリソース情報を取得: '.$parents, $parents);

	$wheres[] = ['parent', '=', $parents];

	// 取得
	$query = \EvolutionCMS\Models\SiteContent::query()->where($wheres)->where(function ($query) use ($orWheres) {
		foreach ($orWheres as $orWhere) {
			$query->orWhere(...$orWhere);
		}
	});

	// 並び替え
	if (!empty($sort)) {
		foreach (explode(',', $sort) as $sortBy) {
			if (empty($sortBy)) continue;
			list($column, $order) = explode(' ', trim($sortBy));
			$query = $query->orderBy($column, $order);
		}
	}

	// 表示数
	if ($display > 0) $query->limit($display);

	$query = $query->get();
	foreach ($query as $result) $result->tv->pluck('value', 'name');
	$results = $query->toArray();

	// evo()->addLog('['.$snippetName.'] 件数：'.count($results), $results);
}

// 指定したリソース情報を取得
else if (isset($documents) && !empty($documents)) {
	// evo()->addLog('['.$snippetName.'] 指定したリソース情報を取得: '.$documents, $documents);

	$docIds = explode(',', $documents);

	// 取得
	$query = \EvolutionCMS\Models\SiteContent::query()->whereIn('id', $docIds)->where($wheres)->where(function ($query) use ($orWheres) {
		foreach ($orWheres as $orWhere) {
			$query->orWhere(...$orWhere);
		}
	});

	// 並び替え
	if (!empty($sort)) {
		foreach (explode(',', $sort) as $sortBy) {
			if (empty($sortBy)) continue;
			list($column, $order) = explode(' ', trim($sortBy));
			$query = $query->orderBy($column, $order);
		}
	}

	$query = $query->get();
	foreach ($query as $result) $result->tv->pluck('value', 'name');
	$results = $query->toArray();

	// 順序をdocumentsの並びにあわせる
	if (count($docIds) > 1) {
		$results = array_reduce($docIds, function($r, $docId) use($results) {
			foreach ($results as $data) {
				if ($data['id'] == $docId) {
					$r[] = $data;
					return $r;
				}
			}
		}, []);
	}

	// if ($results) evo()->addLog('['.$snippetName.'] 件数：'.count($results), $results);
}

if (!isset($results)) return '';

$subHtml = '';

// リストの構築
foreach ($results as $data) {
	$childCount = count(evo()->getDocumentChildren($data['id'], 1, 0, 'id'));

	// evo()->addLog('['.$snippetName.'] current id: '.$currentDocId.', this id: '.$data['id'], $data);

	// エイリアス取得
	$alias = evo()->getAliasListing($data['id']);
	// evo()->addLog('['.$snippetName.'] エイリアス', $alias);

	$url = $alias['path'].(!empty($alias['path']) ? '/' : '').$alias['alias'].($alias['isfolder'] ? '/' : $modx->config['friendly_url_suffix']);
	$url = preg_replace('/\/index\.html$/', '/', $url);
	$url = preg_replace('/^index\.html$/', '', $url);

	$tvNames = array_reduce(isset($data['tpl']['tvs']) ? $data['tpl']['tvs'] : [], function($tvs, $tv) {
		$tvs[$tv['id']] = $tv['name'];
		return $tvs;
	}, []);

	$tvs = array_reduce(isset($data['template_values']) ? $data['template_values'] : [], function($tvs, $tv) use ($tvNames, $tvPrefix) {
		$tvs[$tvPrefix.$tvNames[$tv['tmplvarid']]] = $tv['value'];
		return $tvs;
	}, []);

	// evo()->addLog('['.$snippetName.'] テンプレート変数', $data['template_values']);
	// evo()->addLog('['.$snippetName.'] テンプレート変数名', $tvNames);

	unset($data['tpl']);
	unset($data['template_values']);

	// プレースホルダーの初期設定
	$placeholder = array_merge([
		'title' => $data['pagetitle'],
		'url'   => $url
	], $data, $tvs);

	// evo()->addLog('['.$snippetName.'] プレースホルダー', $placeholder);

	// サブリソースがあれば構築
	if ($maxDepth == -1 || ($maxDepth > 1 && $childCount > 0)) {
		$placeholder['wrap'] = $modx->runSnippet($modx->getSnippetName(), [
			'parents'     => $data['id'],
			'where'       => $where,
			'maxDepth'    => $maxDepth == -1 ? $maxDepth : $maxDepth - 1,
			'publicState' => $publicState,
			'outerTpl'    => $outerTpl,
			'rowTpl'      => $rowTpl,
			'sort'        => $sortBy
		]);
	}

	// HTMLを生成
	$subHtml .= preg_match('/^@CODE:/', $rowTpl) ?
		$modx->parseText(preg_replace('/^@CODE:/', '', $rowTpl), $placeholder) :
		$modx->parseChunk($rowTpl, $placeholder, '[+', '+]');
}

// 出力するものがない場合
if (empty($subHtml)) {
	return preg_match('/^@CODE:/', $noResults) ?
		$modx->parseText(preg_replace('/^@CODE:/', '', $noResults)) :
		$modx->parseChunk($noResults, [], '[+', '+]');
}

// アウターHTMLを生成し出力
return preg_match('/^@CODE:/', $outerTpl) ?
	$modx->parseText(preg_replace('/^@CODE:/', '', $outerTpl), [
		'wrap' => $subHtml
	]) : $modx->parseChunk($outerTpl, [
		'wrap' => $subHtml
	], '[+', '+]');
