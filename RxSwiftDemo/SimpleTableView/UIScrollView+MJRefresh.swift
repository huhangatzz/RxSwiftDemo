import UIKit
import MJRefresh

extension UIScrollView {

    /// 配置下拉刷新和上拉加载。
    func configureRefresh(
        onRefresh: @escaping () -> Void,
        onLoadMore: @escaping () -> Void
    ) {
        mj_header = MJRefreshNormalHeader(refreshingBlock: onRefresh)

        let footer = MJRefreshAutoNormalFooter(refreshingBlock: onLoadMore)
        footer.setTitle("没有更多数据", for: .noMoreData)
        footer.isHidden = true
        mj_footer = footer
    }

    /// 主动触发一次下拉刷新。
    func beginRefreshing() {
        mj_header?.beginRefreshing()
    }

    /// 结束刷新；没有新数据时展示“没有更多数据”。
    func endRefreshing(hasMoreData: Bool) {
        //结束头部刷新
        mj_header?.endRefreshing()
        mj_footer?.isHidden = false

        if hasMoreData {
            mj_footer?.resetNoMoreData()
            mj_footer?.endRefreshing()
        } else {
            mj_footer?.endRefreshingWithNoMoreData()
        }
    }
}
